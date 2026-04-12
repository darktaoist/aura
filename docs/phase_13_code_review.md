# Aura (gwansang) — Phase 13 Code Review
> Sub-agent: `code-reviewer`  
> 기준: `flutter analyze` 0 issues, 20 tests pass 상태에서 릴리스 전 심층 리뷰

---

## Executive Summary

Aura 코드베이스는 Clean Architecture 기반의 명확한 feature 분리, 합리적인 Riverpod 2.x 프로바이더 토폴로지, 명세 준수 수준이 높은 구조적으로 견고한 Flutter 앱이다. `flutter analyze` 0 issues + 20 tests green은 강력한 기반이다. 단, 아래 항목들이 릴리스 전 반드시 해결되어야 한다:

1. Supabase Storage bucket RLS 정책이 완전히 누락 — face/palm 이미지 무단 접근 위험
2. `readings` 테이블 INSERT 정책이 `user_id = null` 허용 — 익명 데이터 주입 가능
3. `AuthRepository.deleteAccount`가 클라이언트에서 `auth.admin.deleteUser` 호출 — service_role 필요
4. `ModelSetupNotifier._listFiles/_directoryExists` 스텁 구현 — 항상 다운로드로 폴백
5. `FaceResultPage`가 `FaceResultNotifier`/`GemmaService`를 우회 — RAG가 실제로 동작하지 않음
6. `SplashPage`에서 Gemma 모델 상태 미확인 — `/splash ↔ /home` 무한 루프 위험

### Severity 집계

| Severity | Count |
|---|---:|
| CRITICAL | 5 |
| HIGH | 11 |
| MEDIUM | 12 |
| LOW | 9 |
| INFO | 6 |
| **Total** | **43** |

---

## 1. Security

### 1.1 [CRITICAL] Storage bucket `readings` RLS 마이그레이션 누락
- **위치**: `supabase/migrations/` (storage 정책 파일 없음)
- **설명**: `reading_repository.dart:24-40`이 `storage.from('readings')`에 `{userId}/{uuid}.jpg`로 업로드하고, `auth_repository.dart:74-81`이 해당 버킷을 list/delete한다. 버킷을 생성하거나 `storage.objects` RLS 정책을 정의하는 마이그레이션이 없다. 프로덕션에서 업로드 실패 또는 Public 버킷 생성 시 모든 인증 사용자가 타인의 얼굴 사진에 접근 가능 — 심각한 PII 노출.
- **수정**: storage 정책 마이그레이션 추가
```sql
insert into storage.buckets (id, name, public) values ('readings','readings',false)
on conflict (id) do nothing;

create policy "readings_owner_rw" on storage.objects
  for all to authenticated
  using (bucket_id='readings' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id='readings' and (storage.foldername(name))[1] = auth.uid()::text);
```

### 1.2 [CRITICAL] `readings_insert_own` 정책이 익명 INSERT 허용
- **위치**: `supabase/migrations/20260412000006_rls_readings.sql:8-10`
- **설명**: `with check (user_id is null or auth.uid() = user_id)` — `anon` 역할도 `user_id=null`로 INSERT 가능. 명세 §RLS "readings는 `user_id = auth.uid()` 만 CRUD"에 위배. 익명 데이터 주입 및 DB 비용/악용 가능.
- **수정**: `user_id not null` 제약 추가, 정책을 `with check (auth.uid() = user_id)`로 강화.

### 1.3 [CRITICAL] `AuthRepository.deleteAccount`가 클라이언트에서 `auth.admin.deleteUser` 호출
- **위치**: `lib/data/supabase/auth_repository.dart:86`
- **설명**: `_client.auth.admin.deleteUser(uid)`는 `service_role` JWT가 필요. anon 키 클라이언트로 호출 시 실패(고아 계정 생성) 또는, 개발자가 실수로 service key를 사용하면 APK에 내장. 명세 §12 명시 위반.
- **수정**: Edge Function `delete-account`로 이전. 사용자 JWT를 받아 서버측에서 service role로 Storage 및 auth user 삭제.

### 1.4 [HIGH] Kakao 로그인이 session에 access_token만 전달 — refresh token 없음
- **위치**: `lib/data/supabase/auth_repository.dart:57`
- **설명**: `setSession(data['access_token'] as String)` — Supabase `setSession`은 refresh token이 필요. 세션 만료 시 자동 로그아웃, 토큰 갱신 불가.
- **수정**: Edge Function이 `{access_token, refresh_token}` 반환, 클라이언트는 `setSession(refreshToken: ...)` 호출.

### 1.5 [HIGH] Google OAuth `redirectTo` scheme이 AndroidManifest에 미등록
- **위치**: `lib/data/supabase/auth_repository.dart:29`
- **설명**: `io.supabase.gwansang://login-callback/`에 대응하는 `<intent-filter>`가 `AndroidManifest.xml`에 없으면 OAuth 딥링크 콜백이 앱으로 돌아오지 않아 무한 브라우저 대기.
- **수정**: Manifest에 `android:scheme="io.supabase.gwansang"` intent-filter 추가, Supabase 대시보드 Auth → URL Configuration에 URL 등록.

### 1.6 [HIGH] 릴리스 빌드에서 Supabase 환경변수 누락 시 앱이 나중에 크래시
- **위치**: `lib/core/constants/app_constants.dart:3-6`
- **설명**: `String.fromEnvironment`가 빈 문자열 반환 시 `Supabase.initialize`가 실패 없이 진행, 실제 API 호출 시점에서 모호한 에러 발생.
- **수정**: Release 모드에서 non-empty 검증 후 `throw StateError('SUPABASE_* not configured')` early fail.

### 1.7 [HIGH] Storage 업로드 시 JPEG 바이트 검증 없음
- **위치**: `lib/data/supabase/reading_repository.dart:24-40`
- **설명**: content-type이 `image/jpeg`로 하드코딩되나 실제 바이트 검증 없음.
- **수정**: 매직 바이트(`FF D8 FF`) 검증 또는 caller에서 content-type 전달.

### 1.8 [MEDIUM] `ragSearch`가 클라이언트에서 768차원 임베딩 전송
- **위치**: `lib/data/supabase/reading_repository.dart:111-137`
- **설명**: 임베딩을 어디서 생성하는지 불명확. `embed-text`는 어드민 전용(§10). 임베딩 생성을 Edge Function에서 처리하면 무제한 OpenAI 프록시가 될 수 있음.
- **수정**: 온디바이스 임베딩이면 명시, 서버측이면 rate limit 적용.

### 1.9 [MEDIUM] 랜드마크 JSON(생체인식 유사 데이터) 서버 저장 — 개인정보처리방침 명시 필요
- **위치**: `lib/data/supabase/reading_repository.dart:53-90`
- **설명**: 468 랜드마크는 GDPR/PIPA상 생체정보 템플릿에 해당. 저장 자체는 가능하지만 privacy.md에 명시적으로 기재해야 하며, 계정 삭제 시 cascade delete가 작동해야 함(1.3과 연계).

### 1.10 [LOW] Kakao native key / google-services.json .gitignore 검증 필요
- **설명**: 명세 §12에 `.gitignore` 항목 명시. CI에서 `git ls-files | grep -E 'google-services|KAKAO_NATIVE'`로 커밋 여부 검증 추가 권장.

---

## 2. Architecture

### 2.1 [CRITICAL] `FaceResultPage`가 `GemmaService`와 `FaceResultNotifier`를 우회
- **위치**: `lib/features/face_reading/result/face_result_page.dart:52-82`
- **설명**: 위젯이 직접 `FlutterGemma.getActiveModel` / `createChat` / `generateChatResponseAsync` 호출. `FaceResultNotifier`와 `GemmaService`가 이미 동일 로직을 구현하고 있으며:
  - Notifier의 상태(`isStreaming`, `isSaving`, `error`)가 사용되지 않음
  - RAG(`ragSearch` + `buildLongFormPrompt(ragChunks:...)`)가 실제로 미호출 — 명세 §8.5 Step 1-2 위반
  - 이전 chat 핸들 미해제로 네이티브 메모리 누수
- **수정**: `FaceResultPage`의 ad-hoc 구현 제거, `initState`에서 `ref.read(faceResultNotifierProvider.notifier).analyze(result:..., ragChunks: await repo.ragSearch(...))` 호출, UI는 `ref.watch(faceResultNotifierProvider)` 소비.

### 2.2 [CRITICAL] `ModelSetupNotifier`의 파일시스템 헬퍼가 스텁 — 항상 다운로드 폴백
- **위치**: `lib/features/model_setup/model_setup_notifier.dart:112-122`
- **설명**: `_directoryExists`가 `true`를 무조건 반환하고 `_listFiles`가 `[]`를 반환. 로컬 스캔이 항상 실패하여 불필요한 네트워크 다운로드 발생. 반면 `model_setup_screen.dart:48-64`는 올바른 `dart:io` 스캔 구현을 보유.
- **수정**: `_listFiles`를 실제 `Directory(dir).list()` 구현으로 교체하거나, Riverpod-first 구조로 통합.

### 2.3 [HIGH] `SplashPage`가 Gemma 모델 상태를 미확인 — `/splash ↔ /home` 무한 루프 위험
- **위치**: `lib/features/splash/splash_page.dart:22-32`
- **설명**: Splash가 `locale` 프리퍼런스만 체크하고 `/home`으로 라우팅. `HomePage._checkModel()`은 모델 없으면 `/splash`로 다시 라우팅 → 루프. `/model_setup` 라우트도 미등록.
- **수정**: `app_router.dart`에 `GoRoute('/model_setup')` 추가, splash에서 `FlutterGemma.hasActiveModel()` 체크 후 false이면 `/model_setup`, true이면 `/home` 또는 `/language_select` 라우팅.

### 2.4 [HIGH] `AuthState` 클래스명이 `supabase_flutter.AuthState`와 충돌
- **위치**: `lib/features/auth/auth_notifier.dart:8`
- **설명**: 동일 네임스페이스에 두 `AuthState` 존재. 임포트 확장 시 컴파일 에러 위험.
- **수정**: `AuthUiState`로 이름 변경.

### 2.5 [HIGH] `AuthNotifier.build`의 스트림 구독이 해제되지 않음
- **위치**: `lib/features/auth/auth_notifier.dart:37-41`
- **설명**: `repo.authStateChanges.listen(...)`에 `ref.onDispose` 훅 없음. Riverpod 2.x에서 notifier 재생성 시 구독이 복수 생성, 좀비 콜백 발생.
- **수정**: `final sub = ...; ref.onDispose(sub.cancel);`

### 2.6 [MEDIUM] `GoRoute('/face/result')`의 `state.extra` null 체크 없음
- **위치**: `lib/core/router/app_router.dart:53`
- **설명**: `final result = state.extra as FaceLandmarkResult;` — 딥링크나 새로고침 시 `extra`가 null이면 캐스트 예외 발생.
- **수정**: `if (state.extra is! FaceLandmarkResult) return const _MissingResultPage();`

### 2.7 [MEDIUM] Presentation 레이어가 `flutter_gemma` SDK와 `shared_preferences` 직접 임포트
- **위치**: `lib/features/face_reading/result/face_result_page.dart:2, 5`
- **설명**: Clean Architecture §2 위반 — 프레젠테이션 레이어는 SDK 직접 접근 금지.
- **수정**: 2.1 수정 시 자연스럽게 해결됨.

### 2.8 [MEDIUM] `HomePage`가 `flutter_gemma`를 직접 임포트
- **위치**: `lib/features/home/home_page.dart:2, 23`
- **설명**: `hasActiveModel()` 호출을 위해 SDK 직접 임포트. `GemmaService` 또는 Riverpod provider로 추상화 필요.

### 2.9 [LOW] `SupabaseClient` provider가 `Supabase.instance` late-init에 의존
- **위치**: `lib/data/supabase/supabase_client.dart:8`
- **설명**: `Supabase.initialize` 누락 시 provider 첫 접근 시점에서 모호한 에러 발생.

### 2.10 [INFO] `palm_reading` result 페이지 스텁 처리
- **위치**: `lib/core/router/app_router.dart:62-64`
- **설명**: Phase 1 범위 내 acceptable; 이슈 트래커 등록 권장.

---

## 3. Correctness

### 3.1 [HIGH] `FaceResultPage`가 Chat 핸들을 close하지 않음
- **위치**: `lib/features/face_reading/result/face_result_page.dart:60-82`
- **설명**: `createChat` 호출 후 `chat` 핸들이 dispose 시 해제되지 않음. 결과 페이지 반복 진입/탈출 시 네이티브 KV 캐시 누적.
- **수정**: notifier에 `Chat? _chat` 필드 보유, `ref.onDispose`에서 close.

### 3.2 [HIGH] NV21 변환에서 `rowStride`를 미반영 — 일부 기기에서 랜드마크 위치 오류
- **위치**: `lib/data/mediapipe/face_mesh_processor.dart:88`
- **설명**: 비인터리브 소스에서 `uBytes.length * 2` 크기 VU 버퍼 생성 후 `vuBytesPerRow: image.width` 설정. Android YUV_420_888의 U/V 평면은 `rowStride != width/2`인 경우 있음(Samsung, Pixel 6a). Row 패딩 미반영 시 행 정렬 오류 → 랜드마크 위치 왜곡.
- **수정**: row-by-row 재구성으로 `uvRowStride`와 `uvPixelStride` 준수:
```dart
final uvRowStride = uPlane.bytesPerRow;
final uvPixelStride = uPlane.bytesPerPixel ?? 1;
for (int y = 0; y < h ~/ 2; y++) {
  for (int x = 0; x < w ~/ 2; x++) {
    final srcIdx = y * uvRowStride + x * uvPixelStride;
    final dstIdx = y * w + x * 2;
    vu[dstIdx]     = vBytes[srcIdx];
    vu[dstIdx + 1] = uBytes[srcIdx];
  }
}
```

### 3.3 [HIGH] 안정도 카운터가 단 1프레임 저점수에도 즉시 리셋
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:70-72`
- **설명**: 눈 깜빡임/조명 반사 1프레임에 3초 카운터가 0으로 리셋. 사용자 경험 심각하게 저하.
- **수정**: 단일 프레임 리셋 대신 점진 감소(예: `max(0, _stabilityCount - 5)`), 또는 N 연속 저점수 프레임 이후 리셋.

### 3.4 [HIGH] 15fps throttle이 실제로 적용되지 않음
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:61`
- **설명**: `AppConst.frameThrottleMs`가 정의되어 있으나 `_onFrame`에서 미사용. 카메라 스트림 전체 fps(약 30fps)로 처리 — CPU/배터리 2배 소모.
- **수정**:
```dart
if (DateTime.now().difference(_lastProcessedAt).inMilliseconds < AppConst.frameThrottleMs) return;
_lastProcessedAt = DateTime.now();
```

### 3.5 [HIGH] `FaceResultPage`가 `ragChunks`를 항상 빈 배열로 전달 — RAG 미작동
- **위치**: `lib/features/face_reading/result/face_result_page.dart:67-70`
- **설명**: `PromptBuilder.buildLongFormPrompt` 호출 시 `ragChunks: const []`. 명세 §8.5 Step 1 미이행.
- **수정**: 2.1과 함께 해결 — `analyze` 호출 전 `ragSearch` 결과 전달.

### 3.6 [MEDIUM] `_parseSections` 정규식에 multiLine 플래그 없음
- **위치**: `lib/features/face_reading/result/face_result_page.dart:89-95`
- **설명**: `caseSensitive:false`와 함께 컨텐츠 내 `## nosebleed` 형태의 우발적 매칭 가능.
- **수정**: `multiLine:true` + `^##` 앵커 추가.

### 3.7 [MEDIUM] `_extractFeatures`가 랜드마크 크기를 152로 가드
- **위치**: `lib/data/mediapipe/face_mesh_processor.dart:94`
- **설명**: 현재 최대 인덱스(152)로 가드는 동작하지만, 향후 인덱스 추가 시 IOB 위험. `LandmarkPairs.requiredSize = 468` 상수로 핀.

### 3.8 [MEDIUM] `noseRatio` fallback이 매직 값 0.5 반환
- **위치**: `lib/data/mediapipe/face_mesh_processor.dart:108`
- **설명**: `faceHeight == 0` 시 0.5 반환으로 zero-landmark 프레임을 "균형잡힘"으로 설명. `null`/NaN 반환 후 분석 스킵이 바람직.

### 3.9 [MEDIUM] `PromptBuilder` 임계값이 단위 없는 매직 넘버
- **위치**: `lib/data/gemma/prompt_builder.dart:160-177`
- **설명**: `_eyeDesc`의 0.18/0.14 등이 face-normalized인지 image-normalized인지 미기재. 코멘트 + face-relative 비율로 전환 권장.

### 3.10 [LOW] `AuthNotifier`가 tokenRefreshed 이벤트에도 상태 갱신
- **위치**: `lib/features/auth/auth_notifier.dart:38-40`
- **설명**: 이메일 변경/프로바이더 연결 시 id가 동일해 stale 상태 유지 가능.

### 3.11 [LOW] `kScanDirs`가 Android 경로만 포함
- **위치**: `lib/features/model_setup/model_config.dart:80-86`
- **설명**: iOS에서 무의미한 경로 탐색. `Platform.isAndroid` 가드 필요.

### 3.12 [LOW] `_frameCount % 30 == 1` + 500ms 이중 로그 게이트
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:76-83`
- **설명**: 시간 기반 게이트만 유지하면 충분.

---

## 4. Performance

### 4.1 [HIGH] 카메라 프레임마다 `setState` → 전체 페이지 재빌드
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:85`
- **설명**: `setState`가 `CameraPreview`를 포함한 전체 `Stack` 재빌드. 15fps에서 초당 15회 전체 UI 재빌드.
- **수정**: `ValueNotifier<FaceLandmarkResult?>` + `RepaintBoundary` + `ValueListenableBuilder`로 랜드마크 오버레이만 분리.

### 4.2 [HIGH] `dispose`에서 `stopImageStream` 완료 대기 없음
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:91-97`
- **설명**: `dispose`가 async를 기다리지 않아 in-flight 프레임 처리 중 dispose된 processor 참조 가능.
- **수정**: `await _camera?.stopImageStream(); await _faceMesh?.dispose();` + `_disposed` 플래그.

### 4.3 [MEDIUM] `GemmaService.dispose`가 있으나 provider가 없어 생명주기 미정의
- **위치**: `lib/data/gemma/gemma_service.dart:89-92`
- **설명**: `gemmaServiceProvider` 없음 → `ref.onDispose` 불가 → 네이티브 모델 핸들 누수 가능.
- **수정**: keepAlive provider 생성 및 disposal 등록.

### 4.4 [MEDIUM] NV21 `Uint8List` 매 프레임 새로 할당
- **위치**: `lib/data/mediapipe/face_mesh_processor.dart:75`
- **설명**: 15fps에서 지속적인 GC 압력.
- **수정**: `create()`에서 한번 할당 후 재사용.

### 4.5 [LOW] `GoogleFonts.notoSansKr()` 런타임 다운로드
- **위치**: `lib/core/theme/app_theme.dart:8`
- **설명**: 네트워크 없을 때 폰트 없음, 첫 실행 플리커, 한국 사용자 개인정보 우려.
- **수정**: TTF를 `assets/fonts/`에 번들링, `GoogleFonts.config.allowRuntimeFetching = false`.

---

## 5. Reliability

### 5.1 [HIGH] 카메라 권한 거부 시 UI 무한 로딩
- **위치**: `lib/features/face_reading/camera/face_camera_page.dart:40-59`
- **설명**: `CameraException` 발생 시 `CircularProgressIndicator`가 영구 표시.
- **수정**: try/catch + `PermissionDeniedWidget` + `openAppSettings()` 버튼.

### 5.2 [HIGH] `_startAnalysis`에 try/catch 없음
- **위치**: `lib/features/face_reading/result/face_result_page.dart:52-82`
- **설명**: Gemma 로드 실패/스트림 에러 시 spinner가 영구 표시, 사용자 피드백 없음.
- **수정**: try/catch → error state 표시.

### 5.3 [MEDIUM] `FaceResultNotifier.analyze`에서 `createChat`/스트림 예외 미처리
- **위치**: `lib/features/face_reading/result/face_result_notifier.dart:53-83`
- **설명**: 에러 발생 시 `isStreaming:true` 상태 고착.
- **수정**: try/catch → `state.copyWith(isStreaming:false, error:e.toString())`.

### 5.4 [MEDIUM] `AuthNotifier.signInWithGoogle` 성공 시 `isLoading` 미해제
- **위치**: `lib/features/auth/auth_notifier.dart:45-52`
- **설명**: `isLoading=true`가 error만 아니면 해제되지 않아 OAuth 성공 후에도 로딩 UI 지속.
- **수정**: `authStateChanges` 리스너에서 `isLoading:false` 리셋.

### 5.5 [MEDIUM] `ModelSetupScreen._registerFile`이 에러를 삼키고 무음 폴백
- **위치**: `lib/features/model_setup/model_setup_screen.dart:75-80`
- **설명**: 로컬 파일 손상/권한 오류 시 사용자 모르게 전체 다운로드 시작.
- **수정**: 폴백 전 정보 타일 표시.

### 5.6 [MEDIUM] `SettingsPage._clearCache`가 no-op이면서 성공 snackbar 표시
- **위치**: `lib/features/settings/settings_page.dart:123-143`
- **설명**: 실제 파일 삭제 없이 "캐시가 삭제되었습니다" 표시.
- **수정**: `getTemporaryDirectory()` 실제 삭제 또는 메뉴 항목 제거.

### 5.7 [LOW] `HistoryNotifier.deleteReading`이 optimistic update 없이 `invalidateSelf`
- **위치**: `lib/features/history/history_notifier.dart:19-22`
- **설명**: 삭제 후 round-trip 플래시 발생. Minor UX 개선 여지.

### 5.8 [LOW] `SplashPage._init`이 `_checkFirstRun` 예외 무시
- **위치**: `lib/features/splash/splash_page.dart:22-27`
- **설명**: SharedPreferences 오류 시 splash 영구 고착.

---

## 6. Code Quality

### 6.1 [MEDIUM] 위젯 전반에 한국어 하드코딩 — 다국어 미적용
- **해당 파일**: `face_camera_page.dart`, `face_result_page.dart`, `home_page.dart`, `settings_page.dart`, `splash_page.dart`, `model_setup_screen.dart`
- **설명**: ARB 파일과 gen-l10n은 존재하나 실제 `AppLocalizations.of(context)!` 미사용. 4개 언어 수용기준 미충족.
- **수정**: 문자열을 ARB 키로 추출, `AppLocalizations`로 교체.

### 6.2 [MEDIUM] `_sections` getter가 매 build마다 6개 정규식 실행
- **위치**: `lib/features/face_reading/result/face_result_page.dart:36`
- **설명**: 스트리밍 중 수백 회의 불필요한 파싱.
- **수정**: `_lastParsedText` + `_cachedSections` 메모이제이션.

### 6.3 [LOW] `modelSizeGb: 2.5` 하드코딩 — E4B(5GB)가 기본일 때 잘못된 진행률 표시
- **위치**: `lib/features/home/home_page.dart:71`
- **수정**: `modelSizeGb: kDefaultModel.sizeGb`

### 6.4 [LOW] 버전 문자열 하드코딩 ('1.0.0+1')
- **위치**: `lib/features/settings/settings_page.dart:34`
- **설명**: 버전 범프 시 수동 업데이트 필요. `package_info_plus` pubspec 추가 권장.

### 6.5 [LOW] `_Phase` enum이 `model_setup_screen.dart`와 `model_setup_notifier.dart`에 중복
- **설명**: 2.2 수정 시 통합됨.

### 6.6 [LOW] `debugPrint` 로그 태그 비일관적, 릴리스 빌드에서도 출력
- **설명**: `package:logging` 도입 또는 릴리스 빌드에서 suppression 권장.

### 6.7 [LOW] `AppDuration.progressUpdate` / `streamCursor` 미사용 상수
- **위치**: `lib/core/theme/app_colors.dart:56-57`
- **수정**: 사용하거나 제거.

### 6.8 [INFO] `kKeyLandmarks` 맵 키가 한국어
- **위치**: `lib/domain/physiognomy/landmark_index.dart:2-20`
- **설명**: UI 표시 시 다국어 처리 필요. enum으로 키 변경 권장.

### 6.9 [INFO] Notifier 상태 클래스가 Freezed(Reading)와 수동(AuthState, FaceResultState) 혼재
- **설명**: 일관성을 위해 Freezed 통일 권장.

### 6.10 [INFO] CI의 build_runner 후 `.g.dart` drift 검증 없음
- **위치**: `.github/workflows/ci.yml:26`
- **수정**: `git diff --exit-code` 추가로 stale 생성 파일 PR 방지.

---

## 7. CI/CD

### 7.1 [MEDIUM] 커버리지 최저 기준 없음
- **위치**: `.github/workflows/ci.yml:35-40`
- **수정**: `lcov --summary` 기반 라인 커버리지 60% 게이트 추가.

### 7.2 [LOW] APK 빌드만 존재 — Google Play는 AAB 필요
- **수정**: `flutter build appbundle --release` 릴리스 job 추가.

### 7.3 [LOW] 에뮬레이터/통합 테스트 job 없음
- **설명**: 네이티브 MediaPipe FFI + 카메라 코드를 위한 최소 스모크 테스트 권장.

### 7.4 [INFO] `secrets.SUPABASE_URL`이 테스트에서 제외
- **설명**: 올바름 — 테스트는 실제 Supabase에 접근하지 않아야 함.

---

## 릴리스 전 필수 수정 항목 (CRITICAL + HIGH)

의존성/영향도 순 정렬:

| # | ID | 제목 | 파일 |
|---:|---|---|---|
| 1 | 1.1 | Storage bucket `readings` RLS 마이그레이션 추가 | `supabase/migrations/` (신규) |
| 2 | 1.2 | `readings` INSERT 정책 익명 허용 제거 + `user_id not null` | `20260412000006_rls_readings.sql`, `20260412000003_readings.sql` |
| 3 | 1.3 | `deleteAccount` → Edge Function `delete-account` 이전 | `auth_repository.dart`, Edge Function 신규 |
| 4 | 2.1 | `FaceResultPage` → `FaceResultNotifier` 배선 + RAG 주입 | `face_result_page.dart`, `face_result_notifier.dart` |
| 5 | 2.2 | `ModelSetupNotifier` 파일시스템 헬퍼 실제 구현 | `model_setup_notifier.dart` |
| 6 | 2.3 | Splash `hasActiveModel()` 체크 + `/model_setup` 라우트 | `splash_page.dart`, `app_router.dart` |
| 7 | 2.4 | `AuthState` → `AuthUiState` 이름 충돌 해결 | `auth_notifier.dart` |
| 8 | 2.5 | `authStateChanges` 구독 `ref.onDispose` 등록 | `auth_notifier.dart` |
| 9 | 1.4 | Kakao Edge Function refresh token 반환 + client setSession | `auth_repository.dart` |
| 10 | 1.5 | Google OAuth redirect scheme AndroidManifest 등록 | `android/app/src/main/AndroidManifest.xml` |
| 11 | 1.6 | 릴리스 빌드 Supabase env 미설정 fail-fast | `main.dart` |
| 12 | 1.7 | JPEG 매직 바이트 검증 | `reading_repository.dart` |
| 13 | 3.1 | Chat 핸들 명시적 close (notifier disposal) | `face_result_notifier.dart` |
| 14 | 3.2 | NV21 V/U 재구성 rowStride 준수 | `face_mesh_processor.dart` |
| 15 | 3.3 | 안정도 카운터 점진 감소로 변경 | `face_camera_page.dart` |
| 16 | 3.4 | 15fps throttle 실제 적용 | `face_camera_page.dart` |
| 17 | 3.5 | ragSearch → ragChunks 전달 (2.1과 함께) | `face_result_notifier.dart` |
| 18 | 4.1 | 프레임 setState → ValueNotifier + RepaintBoundary | `face_camera_page.dart` |
| 19 | 4.2 | dispose에서 await stopImageStream + _disposed 플래그 | `face_camera_page.dart` |
| 20 | 5.1 | 카메라 권한 거부 처리 + 재시도 UI | `face_camera_page.dart` |
| 21 | 5.2 | `_startAnalysis` try/catch + 에러 표시 | `face_result_page.dart` |

### 권장 후속 작업 (MEDIUM)
- 다국어 문자열 `AppLocalizations` 전환 (6.1)
- `ModelSetupScreen`/Notifier 일원화 (2.2와 함께)
- `clearCache` 실제 구현 (5.6)
- `modelSizeGb` 동적화 (6.3)
- Layer violation 정리 (2.7, 2.8)
- NV21 버퍼 풀링 (4.4)
- CI 커버리지 게이트 추가 (7.1)
- AAB 빌드 job 추가 (7.2)

---

*v1.0 — Phase 13 완료*

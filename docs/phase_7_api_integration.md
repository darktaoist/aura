# Phase 7 — api-integrator + sdk-developer 산출물
> Supabase · Gemma · MediaPipe 연동 구현
> 에이전트: `api-integrator`, `sdk-developer` | 날짜: 2026-04-12

---

## 1. 구현 파일

### 1.1 Supabase 클라이언트 레이어

| 파일 | 역할 |
|---|---|
| `data/supabase/supabase_client.dart` | `@riverpod SupabaseClient` 싱글톤 provider |
| `data/supabase/auth_repository.dart` | Google OAuth + Kakao(Edge Function) + 회원탈퇴 |
| `data/supabase/reading_repository.dart` | Storage 업로드 · readings CRUD · RAG Edge Function 호출 |

### 1.2 상태 관리 (Riverpod Notifier)

| 파일 | 역할 |
|---|---|
| `features/auth/auth_notifier.dart` | AuthState (user, isLoading, error) + Supabase 구독 |
| `features/face_reading/result/face_result_notifier.dart` | Gemma 스트리밍 + 저장 |
| `features/history/history_notifier.dart` | 기록 조회 + 삭제 |

---

## 2. 인증 플로우 구현 세부

### Google OAuth
```dart
await _client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'io.supabase.gwansang://login-callback/',
);
```
- Supabase 대시보드 → Authentication → Providers → Google 활성화 필요
- AndroidManifest에 intent-filter (deep link) 추가 필요

### Kakao 인증 (3단계 프록시)
```
kakao_flutter_sdk.loginWithKakaoTalk/Account()
  → OAuthToken.accessToken
  → supabase.functions.invoke('kakao-auth', {access_token})
  → response.data['access_token']
  → supabase.auth.setSession(jwt)
```

---

## 3. 저장 플로우 구현 세부

```
FaceResultPage [저장] 탭
  → authNotifier.isLoggedIn?
      false → push('/auth?from=save')
      true  → faceResultNotifier.saveReading(
                userId, landmarkResult, modelUsed, locale
              )
                → readingRepository.uploadImage() (optional, if capture exists)
                → readingRepository.saveReading()
                  → Supabase readings INSERT
```

**Storage 경로 패턴**: `readings/{userId}/{uuid}.jpg`

---

## 4. RAG 연동 (Edge Function)

```dart
// FaceResultNotifier.analyze() 내부
final ragChunks = await ref.read(readingRepositoryProvider).ragSearch(
  type: 'face',
  queryEmbedding: [], // TODO: 텍스트 임베딩 생성 필요 (embed-text EF 또는 온디바이스)
  topK: AppConst.ragTopK,
);
```

**현재 상태**: RAG 쿼리 임베딩 벡터 생성 로직 미구현  
**임시 처리**: `ragChunks = []` 로 RAG 없이 Gemma 단독 분석  
**v1.1 계획**: 온디바이스 임베딩(MiniLM) 또는 Supabase Edge Function `embed-text` 활용

---

## 5. 코드 생성 필요 목록

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

생성 대상:
```
lib/data/supabase/supabase_client.g.dart
lib/data/supabase/auth_repository.g.dart
lib/data/supabase/reading_repository.g.dart
lib/features/auth/auth_notifier.g.dart
lib/features/face_reading/result/face_result_notifier.g.dart
lib/features/history/history_notifier.g.dart
lib/features/model_setup/model_setup_notifier.g.dart
lib/core/router/app_router.g.dart
lib/domain/entities/landmark_result.freezed.dart
lib/domain/entities/landmark_result.g.dart
lib/domain/entities/reading.freezed.dart
lib/domain/entities/reading.g.dart
```

---

## 6. Android 설정 추가 사항

### 6.1 AndroidManifest.xml (Deep Link for Google OAuth)
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.gwansang" android:host="login-callback" />
</intent-filter>
```

### 6.2 Kakao 앱 키 설정
```xml
<!-- AndroidManifest.xml application 태그 내 -->
<meta-data
    android:name="com.kakao.sdk.AppKey"
    android:value="@string/kakao_app_key" />
```
> `android/app/src/main/res/values/strings.xml` 에 `kakao_app_key` 추가  
> **git 커밋 금지** — 환경변수 또는 CI secrets으로 주입

---

## 7. 다음 단계 (Phase 8) 입력 사항

Phase 8 (`unit-tester` + `integration-tester` + `mock-tester`)에서:
1. `PromptBuilder` 단위 테스트 (경계값: landmarks 부족 시 처리)
2. `FaceMeshService._toNv21` 단위 테스트 (interleaved/manual 분기)
3. `ReadingRepository.saveReading` 통합 테스트 (Supabase test db)
4. Mock Supabase client로 RLS 위반 시나리오 검증

---

*Phase 7 완료: 2026-04-12*

# Phase 15 — doc-writer 산출물
> 프로젝트 README · 개발 가이드
> 날짜: 2026-04-12

---

## 개발 시작 가이드

### 전제 조건

| 도구 | 버전 |
|---|---|
| Flutter | 3.38.9 |
| Dart | 3.10.8 |
| Android Studio | Hedgehog 이상 |
| Java | 17 |

### 셋업

```bash
# 의존성
flutter pub get

# 코드 생성 (freezed, riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 다국어
flutter gen-l10n
```

### 환경 변수 설정

```bash
# Supabase (로컬 개발)
export SUPABASE_URL="https://{project}.supabase.co"
export SUPABASE_ANON_KEY="eyJ..."

# 실행
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### AI 모델

앱 첫 실행 시 Gemma 모델 자동 다운로드. 수동 설치:
```bash
adb push gemma-4-E2B-it.litertlm /sdcard/Download/
```

### DB 마이그레이션

```bash
# Supabase CLI 설치
brew install supabase/tap/supabase

# 마이그레이션 적용
supabase db push
```

---

## 폴더 구조 요약

```
lib/
├── main.dart          # 진입점
├── app.dart           # MaterialApp.router
├── core/              # 테마·라우터·상수·다국어
├── data/              # Supabase·Gemma·MediaPipe 레이어
├── domain/            # 엔티티·유즈케이스·랜드마크 인덱스
└── features/          # 화면별 페이지·Notifier
    ├── splash/
    ├── language_select/
    ├── model_setup/
    ├── home/
    ├── auth/
    ├── face_reading/
    ├── palm_reading/
    ├── history/
    ├── settings/
    ├── policy/
    └── terms/

supabase/migrations/   # DDL 마이그레이션
assets/
├── prompts/           # Gemma 시스템 프롬프트 (locale별)
└── legal/             # 약관·개인정보처리방침 (locale별)
```

---

## 진행 현황 (Phase 체계)

| Phase | 에이전트 | 상태 | 산출물 |
|---|---|---|---|
| 1 | spec-parser | ✅ | phase_1_spec-parser.md |
| 2 | architecture-reviewer + api-architect | ✅ | phase_2_architecture.md |
| 3 | data-modeler + schema-validator + migration-manager | ✅ | phase_3_database.md + supabase/migrations/ |
| 4 | token-designer + ux-designer + style-inspector | ✅ | phase_4_design.md |
| 5-6 | component-developer + app-developer | ✅ | phase_5_components.md + lib/ 전체 |
| 7 | api-integrator + sdk-developer | ✅ | phase_7_api_integration.md |
| 8-10 | unit-tester + qa-engineer + security-analyst | ✅ | phase_8_testing.md + test/ |
| 11 | performance-analyst | ✅ | phase_11_performance.md |
| 12 | pipeline-designer + infra-engineer | ✅ | phase_12_cicd.md + .github/workflows/ |
| 13 | code-reviewer | ✅ | phase_13_code_review.md (43 이슈, 21 CRITICAL/HIGH 수정 완료) |
| 14 | store-manager | ✅ | phase_14_store_listing.md |
| 15 | doc-writer | ✅ | phase_15_docs.md |

---

## Phase 13 수정 사항 요약 (2026-04-13)

### 보안 수정
- `supabase/migrations/20260413000001_storage_readings_rls.sql` — Storage bucket readings RLS 추가
- `supabase/migrations/20260413000002_readings_security_hardening.sql` — readings INSERT 정책 강화 (user_id NOT NULL)
- `supabase/functions/delete-account/index.ts` — 회원탈퇴 Edge Function (service_role 서버측 격리)
- `auth_repository.dart` — deleteAccount Edge Function 호출로 변경, Kakao refresh token 처리
- `auth_notifier.dart` — AuthUiState 이름 변경, 구독 ref.onDispose 등록
- `main.dart` — release 빌드 Supabase env 미설정 fail-fast
- `reading_repository.dart` — JPEG 매직 바이트 검증

### 아키텍처 수정
- `splash_page.dart` — FlutterGemma.hasActiveModel() 체크 + 에러 핸들링
- `app_router.dart` — `/model_setup` 라우트 추가, extra null-safe 캐스트
- `model_setup_notifier.dart` — dart:io 실제 파일시스템 스캔 구현
- `face_result_page.dart` — FaceResultNotifier 배선, RAG ragSearch 호출
- `face_result_notifier.dart` — InferenceChat 핸들 disposal, try/catch
- `home_page.dart` — flutter_gemma 직접 임포트 제거, kDefaultModel.sizeGb 동적화

### 정확성·성능 수정
- `face_camera_page.dart` — 15fps throttle 적용, 안정도 점진 감소, ValueNotifier + RepaintBoundary, dispose 안전화, 카메라 권한 거부 UI
- `face_mesh_processor.dart` — NV21 V/U 재구성 rowStride/pixelStride 준수 (Samsung·Pixel 6a 오류)
- `landmark_index.dart` — LandmarkPairs.requiredSize = 468 상수 추가
- `settings_page.dart` — clearCache 실제 getTemporaryDirectory() 삭제 구현

---

## 다음 스텝

1. Supabase 프로젝트 생성 → `supabase db push` (9개 마이그레이션)
2. `SUPABASE_URL`, `SUPABASE_ANON_KEY` GitHub Secrets 설정
3. Kakao 개발자 앱 등록 → native app key → `android/app/src/main/res/values/strings.xml`
4. Google Cloud Console → OAuth client (Android) → SHA-1 등록
5. `android/app/src/main/AndroidManifest.xml` — Google OAuth redirect intent-filter 추가
6. Android 기기에서 실제 테스트:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=eyJ...
   ```
7. RAG용 `physiognomy_kb` / `palmistry_kb` 테이블 초기 데이터 임베딩 (embed-text Edge Function)

---

*Phase 13–14 재완료: 2026-04-13*

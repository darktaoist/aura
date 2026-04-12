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
| 13 | code-reviewer | 🔲 build_runner 실행 후 |
| 14 | store-manager | ✅ | phase_14_store.md |
| 15 | doc-writer | ✅ | phase_15_docs.md |

---

## 다음 스텝

1. `flutter pub get && dart run build_runner build` — 코드 생성 완료
2. `flutter gen-l10n` — 다국어 클래스 생성
3. Supabase 프로젝트 생성 → `supabase db push`
4. `SUPABASE_URL`, `SUPABASE_ANON_KEY` GitHub Secrets 설정
5. Kakao 개발자 앱 등록 → native app key → `strings.xml`
6. Google Cloud Console → OAuth client (Android) → SHA-1 등록
7. Android 기기에서 `flutter run` → 기능 검증

---

*Phase 15 완료: 2026-04-12*

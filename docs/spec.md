# Aura (gwansang) — 기술명세서 v2.0 (통합본)
> 관상·손금 분석 Android 앱. 기존 gwansang 프로젝트 구현체 위에 Aura UX를 확장한다.
> 본 문서는 Claude Code 멀티 에이전트가 단일 세션에서 참조하는 **단일 소스 오브 트루스**.

---

## 1. 프로젝트 개요

| 항목 | 확정값 |
|---|---|
| 표시 앱명 | **Aura (아우라)** |
| 내부 프로젝트명 | gwansang |
| 패키지명 | `kr.co.taoist.gwansang.gwansang` |
| 플랫폼 | Android 1차 / iOS 구조 유지 |
| Flutter / Dart | 3.38.9 / 3.10.8 |
| minSdk / targetSdk | 28 / 34 |
| 백엔드 | Supabase (Auth · Postgres · Storage · Edge Functions · pgvector) |
| 온디바이스 AI | **Gemma 4 E2B / E4B (.litertlm)**, `flutter_gemma ^0.13.2` |
| 얼굴 분석 | `mediapipe_face_mesh ^1.2.4` (FFI, 468 landmarks, xnnpack delegate) |
| 손 분석 | MediaPipe HandLandmarker — Android 네이티브 채널 (1차 face 완성 후 추가) |
| 다국어 | KO / EN / JA / ZH |
| 테마 | Light / Dark |
| 디자인 톤 | 화이트 베이스 · 미니멀 · 부드러운 그라데이션 포인트 |

---

## 2. 시스템 아키텍처

```
Flutter App (Clean Arch + Feature-first)
 ├─ Presentation (Riverpod 2.x + go_router)
 ├─ Domain (UseCase / Entity)
 └─ Data ─┬─ camera + mediapipe_face_mesh (FFI, xnnpack)
          ├─ flutter_gemma (on-device, .litertlm)
          └─ Supabase Client
                   │
     ┌─────────────┴─────────────┐
     │   Supabase (서버리스)      │
     │ Auth · Postgres · Storage  │
     │ pgvector · Edge Functions  │
     └────────────────────────────┘
```

### 2.1 카메라 → 분석 파이프라인
```
카메라 프레임 (YUV420)
  → NV21 변환 (bytesPerPixel 기반 분기)
  → FaceMeshProcessor (FFI, xnnpack)
  → 468 landmarks 추출
  → 17개 관상 특이점 + 파생 지표 계산
  → 5초마다 Gemma 프롬프트 생성
  → fresh chat session 으로 스트리밍 추론
  → 화면 스트리밍 출력
```
- 프레임 처리: **15fps throttle (66ms)**, 콘솔 로그 30프레임마다
- 매 분석마다 **fresh chat session** (context 누적 방지)

---

## 3. 폴더 구조

```
lib/
├── main.dart                      # ProviderScope + Router만
├── app.dart                       # MaterialApp · Theme · l10n
├── core/
│   ├── theme/ · l10n/ · router/ · constants/ · utils/
├── data/
│   ├── supabase/                  # client · auth_repo · reading_repo
│   ├── gemma/
│   │   ├── gemma_service.dart     # FlutterGemma 래퍼
│   │   └── prompt_builder.dart    # 실시간/장문 2종 프롬프트
│   └── mediapipe/
│       └── face_mesh_processor.dart
├── domain/
│   ├── entities/
│   ├── physiognomy/landmark_index.dart  # 17개 인덱스 상수
│   └── usecases/
└── features/
    ├── splash/
    ├── model_setup/               # 기존 model_download_screen 이관
    │   └── model_config.dart      # 구글 드라이브 URL 상수
    ├── language_select/
    ├── home/
    ├── auth/
    ├── face_reading/              # camera_page + result_page
    ├── palm_reading/
    ├── history/
    ├── settings/
    ├── policy/                    # 개인정보처리방침
    └── terms/
```

> 기존 `lib/main.dart`, `lib/model_config.dart`, `lib/model_download_screen.dart` 는 **삭제 금지 · `git mv` 로 이관**.

---

## 4. 핵심 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter: { sdk: flutter }
  flutter_localizations: { sdk: flutter }

  # On-device AI & Vision
  flutter_gemma: ^0.13.2
  mediapipe_face_mesh: ^1.2.4
  camera: ^0.11.4
  image: ^4.8.0

  # Backend
  supabase_flutter: ^2.5.0
  dio: ^5.4.3

  # Auth
  google_sign_in: ^6.2.1
  kakao_flutter_sdk_user: ^1.9.0

  # State / Navigation
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.0.0

  # UI / Utils
  flex_color_scheme: ^7.3.0
  google_fonts: ^6.2.0
  flutter_markdown: ^0.7.0
  lottie: ^3.1.0
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  permission_handler: ^11.3.1
  path_provider: ^2.1.3
  device_info_plus: ^10.1.0
  connectivity_plus: ^6.0.3
  uuid: ^4.4.0
  flutter_svg: ^2.0.10

dev_dependencies:
  flutter_test: { sdk: flutter }
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  freezed_annotation: ^2.4.1
  json_serializable: ^6.8.0
```

### Android 설정 (`android/app/build.gradle.kts`)
```kotlin
namespace = "kr.co.taoist.gwansang.gwansang"
applicationId = "kr.co.taoist.gwansang.gwansang"
minSdk = 28; compileSdk = 34; targetSdk = 34
ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
```

### 권한
- Android: `CAMERA`, `INTERNET`, `WRITE_EXTERNAL_STORAGE (maxSdk 28)`
- iOS (사전 대응): `NSCameraUsageDescription`

---

## 5. 모델 로드·다운로드 (Gemma)

```
첫 실행
  → FlutterGemma.hasActiveModel() 체크
  → true  : 바로 메인
  → false : ModelSetupScreen
      1) 로컬 스캔 (/sdcard/Download 등) → .litertlm 발견 시 fromFile() 등록
      2) 없으면 구글 드라이브에서 자동 다운로드
         → fromNetwork(url).withProgress().install()
```
**모델 선택 기준** (저장된 것이 없을 때): RAM ≥ 8GB && GPU 상위티어 → E4B, 그 외 → E2B.

**모델 URL (`features/model_setup/model_config.dart` 상수):**
| 모델 | 크기 | URL |
|---|---|---|
| E4B | ~5GB | `https://drive.usercontent.google.com/download?id=1aXnYvUAGvoDfojp6AeRx7N6GcIFUmfsy` |
| E2B | ~2.5GB | `https://drive.usercontent.google.com/download?id=1bsRm7Ri0rm13fkcfAvkABZeJa4RnNflE` |

다운로드 진행률은 `LinearProgressIndicator` + 퍼센트 텍스트로 메인 화면 하단 고정.

---

## 6. 코드 패턴 (확정)

### 6.1 YUV420 → NV21 + FaceMesh
```dart
final bool isInterleaved = (vPlane.bytesPerPixel ?? 1) == 2;
// true  → planes[2].bytes 직접 사용
// false → V/U 수동 인터리빙

final processor = await FaceMeshProcessor.create(
  delegate: FaceMeshDelegate.xnnpack,
);
final result = await processor.processNv21(
  nv21,
  rotationDegrees: sensorOrientation,
  mirrorHorizontal: isFront,
);
```

### 6.2 Gemma 초기화 / 추론
```dart
await FlutterGemma.initialize();
final model = await FlutterGemma.getActiveModel(maxTokens: 2048);

// 분석 시작 시 fresh chat
final chat = await model.createChat(
  modelType: ModelType.gemmaIt,
  systemInstruction: kLongFormPrompt,  // 결과화면용 장문 프롬프트
  temperature: 0.7, topK: 40,
);
await chat.addQueryChunk(Message(text: userPrompt, isUser: true));
final stream = chat.generateChatResponseAsync();
```

### 6.3 2종 시스템 프롬프트 (필수 분리)
- **실시간 오버레이용** (`kRealtimePrompt`): 2~3문장 한국어 짧은 피드백
- **결과화면용** (`kLongFormPrompt`): "20년 경력 동양 관상학 전문가, 1000자 이상, 단정어 지양, 섹션 구성(이마·눈·코·입·턱·종합)"
- locale별로 `assets/prompts/{face|palm}_{lang}.txt` 에 분리

---

## 7. 관상 랜드마크 (MediaPipe 468 중 핵심 17)

| 부위 | 인덱스 |
|---|---|
| 이마 | 10 |
| 코끝 | 4 |
| 코다리 | 168 |
| 인중 | 0 |
| 턱 | 152 |
| 왼눈 내각/외각 | 133, 33 |
| 오른눈 내각/외각 | 362, 263 |
| 입 좌/우 | 61, 291 |
| 왼볼 / 오른볼 | 234, 454 |
| 눈썹 내/외 (좌우) | 107, 46, 336, 276 |

**파생 지표**: 눈 간격, 얼굴 높이, 코 위치 비율, 입 너비, 좌우 대칭도.
→ `lib/domain/physiognomy/landmark_index.dart` 에 상수화.

---

## 8. 화면 명세

### 8.1 Splash (`/splash`)
- 화이트 배경 + Aura 로고
- 백그라운드: Supabase 세션 복원 → SharedPreferences 로드 → Gemma 모델 상태 점검
- 최초 실행이면 `/language_select`, 아니면 `/home`

### 8.2 Language Select (`/language_select`) — 최초 1회
- KO / EN / JA / ZH 4개 카드. 선택 시 SharedPreferences 저장 → `/home`

### 8.3 Home (`/home`)
- AppBar: Aura 로고 + 우측 메뉴(설정/약관/로그아웃)
- 카드 2개: **관상 보기** → `/face/camera`, **손금 보기** → `/palm/camera`
- 비로그인 시 배너: "로그인하면 결과를 저장할 수 있습니다"
- 하단: 모델 다운로드 진행률(해당 시)

### 8.4 Auth (`/auth`)
- **저장 시도 시점에만** 유도 (비로그인 분석은 허용)
- Google: Supabase `signInWithOAuth(google)`
- Kakao: kakao_flutter_sdk → access token → **Edge Function `kakao-auth`** 가 검증 후 Supabase JWT 발급 (Supabase 네이티브 미지원이므로 필수)
- 약관/개인정보 동의 체크박스

### 8.5 Face Reading
**Camera (`/face/camera`)**
- 전면 카메라 즉시 프리뷰 + landmark 오버레이(반투명)
- 3초간 검출 안정 → "특이점 추출 완료" → 하단 [관상 결과 보기] 버튼 활성
- 추출 산출물: 468 landmarks + 파생 지표 + 캡처 1장

**Result (`/face/result`)**
1. pgvector `physiognomy_kb` 에서 Top-5 chunk 검색 (Edge Function `rag-search`)
2. 결과화면용 장문 프롬프트에 랜드마크 JSON + RAG 컨텍스트 주입
3. Gemma 스트리밍 출력 → 섹션별 카드(이마/눈/코/입/턱/종합)
4. **1000자 이상** 필수, 단정적 표현 지양
5. 하단: [다시 보기] [저장] [공유] — 저장 시 비로그인이면 `/auth` 후 복귀

### 8.6 Palm Reading
- 구조는 Face와 동일, MediaPipe HandLandmarker 21점
- 왼손/오른손 토글
- RAG 테이블 `palmistry_kb` 사용

### 8.7 History (`/history`)
- 로그인 사용자만. `readings` 테이블 조회. 카드 리스트(타입·날짜·썸네일).

### 8.8 Settings (`/settings`)
테마 · 언어 · 모델(E2B/E4B 전환) · 캐시 삭제 · 로그아웃 · 회원탈퇴 · 버전

### 8.9 Privacy / Terms
`assets/legal/{lang}/privacy.md`, `terms.md` → `flutter_markdown` 렌더링

---

## 9. 데이터 모델 (Supabase)

```sql
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  display_name text, locale text default 'ko',
  created_at timestamptz default now()
);

create table readings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  type text check (type in ('face','palm')) not null,
  image_path text,                 -- Storage: readings/{user}/{uuid}.jpg
  landmarks jsonb not null,
  features jsonb,
  result_text text not null,
  model_used text,                 -- 'E2B' | 'E4B'
  locale text,
  created_at timestamptz default now()
);

create extension if not exists vector;
create table physiognomy_kb (
  id bigserial primary key,
  topic text, content text not null,
  embedding vector(768)
);
create table palmistry_kb (like physiognomy_kb including all);
create index on physiognomy_kb using ivfflat (embedding vector_cosine_ops);
create index on palmistry_kb   using ivfflat (embedding vector_cosine_ops);
```
**RLS**: `readings`는 `user_id = auth.uid()` 만 CRUD. KB 테이블은 anon SELECT만.

---

## 10. Edge Functions

| 함수 | 역할 |
|---|---|
| `kakao-auth` | Kakao access token 검증 → Supabase admin user upsert → JWT 발급 |
| `rag-search` | `{type, query_embedding, top_k}` → pgvector 유사도 검색 |
| `embed-text` | KB 적재 어드민 전용 — OpenAI/로컬 임베딩으로 vector(768) 생성 |

---

## 11. 다국어 (국제화, i18n)

> **원칙: 앱의 모든 화면·위젯·출력물은 KO / EN / JA / ZH 4개 언어를 완전 지원한다.**
> 어떤 화면에도 하드코딩된 한국어(또는 기타 언어) 문자열이 남아 있어서는 안 된다.

### 구현 방식
- `flutter gen-l10n` + `lib/core/l10n/app_{ko,en,ja,zh}.arb` → `lib/core/l10n/generated/`
- **LocaleNotifier** (`lib/core/l10n/locale_notifier.dart`) — Riverpod `keepAlive: true` 상태로 앱 전체에 locale 전파
- `MaterialApp.router`의 `locale:` 파라미터에 `ref.watch(localeNotifierProvider)` 바인딩
- 설정 화면에서 언어 변경 시 `localeNotifierProvider.setLocale(code)` 호출 → 전체 UI 즉시 반응
- Gemma 프롬프트도 locale 별로 분리 (`assets/prompts/{face|palm}_{ko,en,ja,zh}.txt`)
- 약관·개인정보처리방침: `assets/legal/{ko,en,ja,zh}/{terms,privacy}.md` — `Localizations.localeOf(context)`로 동적 로드

### 커버리지 체크리스트
모든 신규 위젯·화면 작성 시 아래를 확인한다:
- [ ] 화면 제목 (AppBar title)
- [ ] 버튼·레이블 텍스트
- [ ] 빈 상태(empty state) 메시지
- [ ] 오류(error) 메시지 및 스낵바
- [ ] 다이얼로그 제목·본문·액션
- [ ] 상대 시간 표현 (n분 전, n시간 전 등)
- [ ] 플레이스홀더(hint) 텍스트
- [ ] 법적 문서(약관·개인정보) 로딩 경로

---

## 12. 보안·권한

- Supabase anon key 만 클라 노출, service_role 은 Edge Function 환경변수
- 사용자 사진: 기본은 로컬 보관, 저장 액션 시에만 Storage 업로드
- `.gitignore` 에 `*.litertlm`, `.env`, `**/google-services.json`
- 빌드 시 `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

---

## 13. Claude Code Sub-agent 작업 매핑

`~/works/gwansang/.claude/agents/` 35개 · `skills/` 24개 활용.

| 단계 | Sub-agent | 산출물 |
|---|---|---|
| 1. 분석 | `spec-parser` | 기능 분해 · 수용 기준 |
| 2. 아키텍처 | `architecture-reviewer` + `api-architect` | 폴더구조·스키마 리뷰 |
| 3. DB | `data-modeler` + `schema-validator` + `migration-manager` | DDL·RLS·pgvector 인덱스·마이그레이션 |
| 4. 디자인 | `token-designer` + `ux-designer` + `style-inspector` | ColorScheme·Typography |
| 5. 공통 위젯 | `component-developer` + `storybook-builder` | CameraOverlay 등 |
| 6. 앱 구현 | `app-developer` | features/* |
| 7. 연동 | `api-integrator` + `sdk-developer` | Supabase·Gemma·MediaPipe 래퍼 |
| 8. 테스트 | `unit-tester` + `integration-tester` + `mock-tester` + `test-strategist` | widget/unit/golden |
| 9. 품질 | `qa-engineer` + `coverage-analyst` + `a11y-auditor` | QA·접근성 |
| 10. 보안 | `security-analyst` + `security-scanner` + `security-auditor` | RLS·키 노출 점검 |
| 11. 성능 | `performance-analyst` | 추론 속도·메모리 |
| 12. CI/CD | `pipeline-designer` + `infra-engineer` + `monitoring-specialist` | Actions·Fastlane·Sentry |
| 13. 리뷰 | `code-reviewer` + `review-synthesizer` + `review-auditor` | 최종 PR 리뷰 |
| 14. 출시 | `store-manager` | 스토어 메타(4개국) |
| 15. 문서 | `doc-writer` | README·API 문서 |

**활용 Skills**: `mobile-app-builder`, `mobile-ux-patterns`, `design-system`, `database-architect`, `api-designer`, `cicd-pipeline`, `test-automation`, `vulnerability-patterns`, `wcag-checker`, `app-store-optimization`.

---

## 14. Acceptance Criteria

1. 모델 캐시 존재 시 스플래시 → 메인 ≤ 3초 (Android 9+ 중급 기기)
2. 얼굴 랜드마크 15fps 안정 유지
3. 결과 텍스트 **1000자 이상** · 4개 언어 자연스러운 문장
4. 비로그인 분석 가능, 저장 액션 시 OAuth 1회로 완료
5. Light/Dark 전환 UI 무결성
6. RLS 위반 시 저장 실패 e2e 통과
7. Play Console 권한 사유 심사 통과
8. **4개 언어(KO/EN/JA/ZH) 완전 지원** — 앱 내 모든 화면·위젯·오류 메시지·약관 문서가 선택된 언어로 출력되며, 설정에서 언어 변경 시 즉시 전체 UI가 전환된다

---

## 15. 향후 확장 (v2.1+)
- iOS 활성화 (Sign in with Apple 포함)
- 사주/타로 모듈 (동일 파이프라인 재사용)
- 결과 PDF·공유 카드 이미지 생성
- 사용자 KB 기여 워크플로우(어드민 검수 → 재임베딩)

---

*v2.0 통합본 끝.*

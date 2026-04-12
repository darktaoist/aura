# Phase 2 — architecture-reviewer + api-architect 산출물
> 폴더 구조 · 라우트 · Riverpod Provider 트리 · API 인터페이스 설계
> 에이전트: `architecture-reviewer`, `api-architect` | 날짜: 2026-04-12

---

## 1. 확정 폴더 구조

```
lib/
├── main.dart                          # ProviderScope + Router 부트스트랩만
├── app.dart                           # MaterialApp.router · Theme · l10n
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # FlexColorScheme Light/Dark
│   │   └── app_colors.dart            # 디자인 토큰 색상 상수
│   ├── l10n/
│   │   ├── app_ko.arb
│   │   ├── app_en.arb
│   │   ├── app_ja.arb
│   │   └── app_zh.arb
│   ├── router/
│   │   └── app_router.dart            # go_router 전체 라우트 테이블
│   ├── constants/
│   │   └── app_constants.dart         # 환경변수 키, 기타 상수
│   └── utils/
│       ├── device_utils.dart          # RAM/GPU 티어 판별
│       └── image_utils.dart           # YUV420 → NV21 변환 유틸
│
├── data/
│   ├── supabase/
│   │   ├── supabase_client.dart       # Supabase.initialize() 래퍼
│   │   ├── auth_repository.dart       # Google/Kakao OAuth, 세션
│   │   └── reading_repository.dart    # CRUD readings + Storage 업로드
│   ├── gemma/
│   │   ├── gemma_service.dart         # FlutterGemma 래퍼 (초기화, 모델 로드)
│   │   └── prompt_builder.dart        # 2종 프롬프트: realtime / longform
│   └── mediapipe/
│       └── face_mesh_processor.dart   # FaceMeshProcessor FFI 래퍼
│
├── domain/
│   ├── entities/
│   │   ├── reading.dart               # Reading(id, userId, type, ...) @freezed
│   │   ├── profile.dart               # Profile @freezed
│   │   └── landmark_result.dart       # LandmarkResult + 파생 지표 @freezed
│   ├── physiognomy/
│   │   └── landmark_index.dart        # 17개 인덱스 Map<String,int> 상수
│   └── usecases/
│       ├── analyze_face_use_case.dart
│       ├── save_reading_use_case.dart
│       └── get_history_use_case.dart
│
└── features/
    ├── splash/
    │   ├── splash_page.dart
    │   └── splash_notifier.dart       # 세션복원·모델상태 체크
    ├── language_select/
    │   └── language_select_page.dart
    ├── model_setup/                   # ← git mv lib/model_config.dart
    │   ├── model_config.dart          # Gemma URL 상수
    │   ├── model_setup_screen.dart    # ← git mv lib/model_download_screen.dart
    │   └── model_setup_notifier.dart  # 다운로드 진행률 Riverpod state
    ├── home/
    │   └── home_page.dart
    ├── auth/
    │   ├── auth_page.dart
    │   └── auth_notifier.dart
    ├── face_reading/
    │   ├── camera/
    │   │   ├── face_camera_page.dart
    │   │   ├── face_camera_notifier.dart
    │   │   └── widgets/
    │   │       ├── landmark_overlay_painter.dart
    │   │       └── stability_indicator.dart
    │   └── result/
    │       ├── face_result_page.dart
    │       ├── face_result_notifier.dart
    │       └── widgets/
    │           └── reading_section_card.dart
    ├── palm_reading/
    │   ├── camera/
    │   │   └── palm_camera_page.dart
    │   └── result/
    │       └── palm_result_page.dart
    ├── history/
    │   ├── history_page.dart
    │   └── history_notifier.dart
    ├── settings/
    │   └── settings_page.dart
    ├── policy/
    │   └── privacy_page.dart
    └── terms/
        └── terms_page.dart

assets/
├── prompts/
│   ├── face_ko.txt   # 장문 관상 프롬프트 (한국어)
│   ├── face_en.txt
│   ├── face_ja.txt
│   ├── face_zh.txt
│   ├── palm_ko.txt
│   ├── palm_en.txt
│   ├── palm_ja.txt
│   └── palm_zh.txt
└── legal/
    ├── ko/
    │   ├── privacy.md
    │   └── terms.md
    ├── en/
    ├── ja/
    └── zh/
```

---

## 2. go_router 라우트 테이블

```dart
// lib/core/router/app_router.dart

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // 인증 상태 기반 리다이렉트 (auth guard)
      final isLoggedIn = ref.read(authNotifierProvider).isLoggedIn;
      final isHistoryPath = state.matchedLocation.startsWith('/history');
      if (isHistoryPath && !isLoggedIn) return '/auth?from=history';
      return null;
    },
    routes: [
      GoRoute(path: '/splash',           builder: SplashPage),
      GoRoute(path: '/language_select',  builder: LanguageSelectPage),
      GoRoute(path: '/home',             builder: HomePage),
      GoRoute(path: '/auth',             builder: AuthPage),        // ?from=
      GoRoute(path: '/face/camera',      builder: FaceCameraPage),
      GoRoute(path: '/face/result',      builder: FaceResultPage),  // extra: LandmarkResult
      GoRoute(path: '/palm/camera',      builder: PalmCameraPage),
      GoRoute(path: '/palm/result',      builder: PalmResultPage),  // extra: HandResult
      GoRoute(path: '/history',          builder: HistoryPage),
      GoRoute(path: '/settings',         builder: SettingsPage),
      GoRoute(path: '/privacy',          builder: PrivacyPage),
      GoRoute(path: '/terms',            builder: TermsPage),
    ],
  );
});
```

**화면 전환 규칙**

| 출발 | 목적지 | 조건 |
|---|---|---|
| `/splash` | `/language_select` | 최초 실행 (SharedPreferences 없음) |
| `/splash` | `/home` | 이미 언어 설정됨 |
| `/home` | `/face/camera` | 관상 보기 카드 탭 |
| `/face/camera` | `/face/result` | 안정 감지 후 [결과 보기] 탭 |
| `/face/result` (저장) | `/auth` (비로그인) | 저장 시 미로그인 |
| `/auth` | 이전 화면 복귀 | 로그인 성공, `?from=` 파라미터 |
| `/history` | `/auth` | 미로그인 접근 시 guard redirect |

---

## 3. Riverpod Provider 트리

```
authNotifierProvider (AsyncNotifier<AuthState>)
  └─ authRepositoryProvider (AuthRepository)
      └─ supabaseClientProvider

modelSetupNotifierProvider (AsyncNotifier<ModelSetupState>)
  └─ gemmaServiceProvider (GemmaService)

faceCameraNotifierProvider (AutoDisposeAsyncNotifier<FaceCameraState>)
  └─ faceMeshProcessorProvider (FaceMeshProcessor)
  └─ gemmaServiceProvider

faceResultNotifierProvider (AutoDisposeAsyncNotifier<FaceResultState>)
  └─ gemmaServiceProvider
  └─ ragSearchProvider (Edge Function rag-search)
  └─ promptBuilderProvider

historyNotifierProvider (AsyncNotifier<List<Reading>>)
  └─ readingRepositoryProvider
      └─ supabaseClientProvider

settingsNotifierProvider (Notifier<SettingsState>)
  └─ sharedPreferencesProvider

themeNotifierProvider (Notifier<ThemeMode>)
  └─ settingsNotifierProvider

localeNotifierProvider (Notifier<Locale>)
  └─ settingsNotifierProvider
```

**상태 클래스 설계 원칙**
- 모든 State는 `@freezed` 불변 객체
- `AsyncNotifier` 사용 (비동기 초기화 포함 기능)
- `autoDispose` — 카메라/결과 페이지처럼 화면 벗어나면 즉시 해제

---

## 4. API 인터페이스 설계 (Supabase / Edge Functions)

### 4.1 Supabase Client (anon key)

```dart
// 초기화
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### 4.2 Auth Repository 인터페이스

```dart
abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithKakao();   // → Edge Function kakao-auth 호출
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}
```

### 4.3 Reading Repository 인터페이스

```dart
abstract class ReadingRepository {
  // Storage 업로드 (저장 액션 시에만)
  Future<String> uploadImage({
    required String userId,
    required Uint8List imageBytes,
  });

  // readings INSERT
  Future<Reading> saveReading({
    required String userId,
    required ReadingType type,
    required String imagePath,
    required Map<String, dynamic> landmarks,
    required Map<String, dynamic>? features,
    required String resultText,
    required String modelUsed,
    required String locale,
  });

  // readings SELECT (RLS: user_id = auth.uid())
  Future<List<Reading>> getHistory(String userId);
}
```

### 4.4 Edge Function: `kakao-auth`

**Request**
```json
POST /functions/v1/kakao-auth
Authorization: Bearer <supabase-anon-key>
Content-Type: application/json

{
  "access_token": "<kakao_access_token>"
}
```

**Response (성공)**
```json
{
  "access_token": "<supabase_jwt>",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "<supabase_refresh_token>"
}
```

**Response (실패)**
```json
{
  "error": "invalid_token",
  "message": "Kakao token validation failed"
}
```

**처리 흐름**
1. Kakao API `/v2/user/me` 호출로 token 검증
2. `kakao_id` → Supabase admin `auth.users` upsert (email: `kakao_{id}@kakao.local`)
3. `supabase.auth.admin.generateLink(type: 'magiclink', ...)` → JWT 발급
4. 클라이언트에 Supabase session 반환

### 4.5 Edge Function: `rag-search`

**Request**
```json
POST /functions/v1/rag-search
Authorization: Bearer <supabase-anon-key>

{
  "type": "face",                    // "face" | "palm"
  "query_embedding": [0.1, 0.2, ...],  // vector(768)
  "top_k": 5
}
```

**Response**
```json
{
  "chunks": [
    {
      "id": 1,
      "topic": "눈 형태",
      "content": "봉황안은 끝이 올라간 눈으로...",
      "similarity": 0.92
    }
  ]
}
```

**SQL (내부 구현)**
```sql
SELECT id, topic, content,
       1 - (embedding <=> $1::vector) AS similarity
FROM physiognomy_kb          -- 또는 palmistry_kb (type으로 분기)
ORDER BY embedding <=> $1::vector
LIMIT $2;
```

### 4.6 Edge Function: `embed-text` (어드민 전용)

**Request**
```json
POST /functions/v1/embed-text
Authorization: Bearer <service-role-key>   // 어드민만

{
  "type": "face",
  "topic": "눈 형태",
  "content": "봉황안은..."
}
```

**처리**: OpenAI `text-embedding-3-small` (dim=768) 또는 로컬 임베딩 모델로 벡터 생성 → `physiognomy_kb` INSERT

---

## 5. 핵심 아키텍처 결정 사항 (ADR)

### ADR-001: 상태관리 — Riverpod 2.x (AsyncNotifier)
- **결정**: `flutter_riverpod ^2.5.1` + `riverpod_generator`
- **이유**: 코드 생성 기반 타입 안전, `autoDispose` 메모리 관리, 비동기 초기화 지원
- **대안**: BLoC — 보일러플레이트 과다; Provider — 타입 안전성 부족

### ADR-002: 라우팅 — go_router (declarative)
- **결정**: `go_router ^14.0.0`
- **이유**: Flutter 공식 권장, `extra` 파라미터로 복잡 객체 전달 가능, deep link 지원
- **주의**: `/face/result`는 `extra: LandmarkResult`로 전달 (URL 파라미터 아님)

### ADR-003: Gemma 추론 — fresh chat session per analysis
- **결정**: 매 분석마다 `model.createChat()` 신규 생성
- **이유**: context 누적 방지, 이전 분석 결과가 현재 분석에 영향 주지 않음
- **비용**: 세션 생성 오버헤드 (≈ 100ms 이하로 허용 범위)

### ADR-004: 이미지 저장 정책 — 저장 액션 시에만 Storage 업로드
- **결정**: 분석 중 캡처는 로컬 메모리·캐시에만 보관
- **이유**: 개인정보 보호 (AC-009), Play Console 심사 대응

### ADR-005: Kakao 인증 — Edge Function 프록시
- **결정**: 클라이언트 → Edge Function `kakao-auth` → Supabase JWT
- **이유**: Supabase는 Kakao OAuth를 네이티브 미지원. `service_role` key를 서버측 보관.

---

## 6. Android 빌드 설정 확인 사항

```kotlin
// android/app/build.gradle.kts
namespace = "kr.co.taoist.gwansang.gwansang"
applicationId = "kr.co.taoist.gwansang.gwansang"
minSdk = 28
compileSdk = 34
targetSdk = 34
ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
```

**권한 (`AndroidManifest.xml`)**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

---

## 7. 다음 단계 (Phase 3) 입력 사항

Phase 3 (`data-modeler` + `schema-validator` + `migration-manager`)에서:

1. `profiles`, `readings`, `physiognomy_kb`, `palmistry_kb` DDL 완성
2. RLS 정책 SQL (readings: `user_id = auth.uid()`)
3. pgvector IVFFlat 인덱스 파라미터 (`lists` = √n)
4. 마이그레이션 파일 번호 체계 (`001_initial.sql`, ...)
5. Storage bucket `readings/` 정책 (authenticated only upload)

---

*Phase 2 완료: 2026-04-12*

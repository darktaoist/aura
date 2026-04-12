# Phase 5 — component-developer + storybook-builder 산출물
> 공통 위젯 구현 · 앱 골격 코드
> 에이전트: `component-developer`, `storybook-builder` | 날짜: 2026-04-12

---

## 1. 구현된 파일 목록

### 1.1 코어 레이어

| 파일 | 내용 |
|---|---|
| `lib/main.dart` | ProviderScope + Supabase/Gemma 초기화 |
| `lib/app.dart` | MaterialApp.router, 다국어, Light/Dark 테마 |
| `lib/core/theme/app_colors.dart` | 색상·간격·반경·애니메이션 토큰 |
| `lib/core/theme/app_theme.dart` | FlexColorScheme Light/Dark 설정 |
| `lib/core/constants/app_constants.dart` | Env(dart-define), AppConst 상수 |
| `lib/core/router/app_router.dart` | go_router 11개 라우트 (Riverpod provider) |
| `lib/core/l10n/app_{ko,en,ja,zh}.arb` | 4개 언어 번역 키 39개 |

### 1.2 도메인 레이어

| 파일 | 내용 |
|---|---|
| `lib/domain/physiognomy/landmark_index.dart` | 17개 핵심 랜드마크 인덱스 Map |
| `lib/domain/entities/landmark_result.dart` | @freezed: LandmarkPoint, FaceFeatures, FaceLandmarkResult |
| `lib/domain/entities/reading.dart` | @freezed: Reading, ReadingType enum |

### 1.3 데이터 레이어

| 파일 | 내용 |
|---|---|
| `lib/data/gemma/prompt_builder.dart` | 2종 프롬프트 분리 (realtime/longform × 4언어) |
| `lib/data/gemma/gemma_service.dart` | FlutterGemma 래퍼, 스트리밍 분리 |
| `lib/data/mediapipe/face_mesh_processor.dart` | FaceMeshService (YUV420→NV21, 파생지표) |

### 1.4 기능 화면

| 화면 | 파일 | 상태 |
|---|---|---|
| Splash | `features/splash/splash_page.dart` | ✅ 완성 |
| 언어 선택 | `features/language_select/language_select_page.dart` | ✅ 완성 |
| 홈 | `features/home/home_page.dart` | ✅ 완성 |
| 인증 | `features/auth/auth_page.dart` | ✅ UI 완성 (OAuth 연동은 Phase 7) |
| 얼굴 카메라 | `features/face_reading/camera/face_camera_page.dart` | ✅ 완성 |
| 얼굴 결과 | `features/face_reading/result/face_result_page.dart` | ✅ 완성 |
| 손금 카메라 | `features/palm_reading/camera/palm_camera_page.dart` | 🔲 v1.1 예정 |
| 손금 결과 | `features/palm_reading/result/palm_result_page.dart` | 🔲 v1.1 예정 |
| 히스토리 | `features/history/history_page.dart` | 🔲 Phase 7 (Supabase 연동 후) |
| 설정 | `features/settings/settings_page.dart` | ✅ UI 완성 |
| 개인정보 | `features/policy/privacy_page.dart` | ✅ 완성 |
| 약관 | `features/terms/terms_page.dart` | ✅ 완성 |

### 1.5 공통 위젯

| 위젯 | 파일 |
|---|---|
| `LandmarkOverlayPainter` | `face_reading/camera/widgets/landmark_overlay_painter.dart` |
| `StabilityIndicator` | `face_reading/camera/widgets/stability_indicator.dart` |
| `ReadingSectionCard` | `face_reading/result/widgets/reading_section_card.dart` |
| `ModelSetupNotifier` | `model_setup/model_setup_notifier.dart` |

### 1.6 이관 파일

| 이전 위치 | 새 위치 | 방법 |
|---|---|---|
| `lib/model_config.dart` | `lib/features/model_setup/model_config.dart` | `git mv` ✅ |
| `lib/model_download_screen.dart` | `lib/features/model_setup/model_setup_screen.dart` | `git mv` ✅ |

---

## 2. pubspec.yaml 업데이트

- 기존 4개 의존성 → spec.md §4 전체 24개 + 4개 dev 의존성으로 확장
- `flutter: generate: true` 추가 (flutter gen-l10n 지원)
- assets 섹션: `assets/prompts/`, `assets/legal/{ko,en,ja,zh}/`

---

## 3. 코드 생성 필요 파일 (build_runner 실행 전)

다음 파일은 `build_runner`가 생성해야 함:

```
lib/domain/entities/landmark_result.freezed.dart
lib/domain/entities/landmark_result.g.dart
lib/domain/entities/reading.freezed.dart
lib/domain/entities/reading.g.dart
lib/features/model_setup/model_setup_notifier.g.dart
lib/core/router/app_router.g.dart
```

**실행 명령:**
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

---

## 4. Phase 7 연동 전 TODO 목록

| 항목 | 위치 |
|---|---|
| Supabase auth (Google/Kakao OAuth) | `auth_page.dart` _signInWithGoogle/_signInWithKakao |
| Supabase readings 저장 | `face_result_page.dart` _onSave |
| RAG Edge Function 연동 | `face_result_page.dart` _startAnalysis |
| Gemma Riverpod provider | `face_result_page.dart` GemmaService 임시 싱글톤 교체 |
| History 리스트 조회 | `history_page.dart` |
| Settings 테마/모델 토글 저장 | `settings_page.dart` |

---

## 5. 컴포넌트 스토리 (storybook-builder 명세)

Phase 5에서 직접 Storybook을 실행하지 않으나, 각 위젯의 변형 케이스:

### ReadingSectionCard
- `isStreaming: true` — 커서 깜박임
- `isStreaming: false` — 정적 텍스트
- `initiallyExpanded: false` — 접힌 상태

### StabilityIndicator
- `progress: 0.0, isStable: false` — 초기 (진행바 비어있음)
- `progress: 0.6, isStable: false` — 진행 중
- `progress: 1.0, isStable: true` — 완료 (체크 아이콘)

### LandmarkOverlayPainter
- 468점 모두 표시
- 핵심 17점 빨간 강조 + 레이블

---

*Phase 5 완료: 2026-04-12*

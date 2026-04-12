# Phase 1 — spec-parser 산출물
> 기능 분해 · 수용 기준 (Acceptance Criteria)
> 에이전트: `spec-parser` | 날짜: 2026-04-12

---

## 1. 기능 분해 (Feature Breakdown)

### 1.1 앱 진입 플로우

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-001 | Splash | 로고 표시, 백그라운드 세션 복원·모델 상태 점검 | P0 |
| F-002 | Language Select | 최초 1회 4개 언어 선택(KO/EN/JA/ZH), SharedPreferences 저장 | P0 |
| F-003 | App Router | 최초 실행 여부 분기(`/language_select` vs `/home`) | P0 |
| F-004 | Theme | Light/Dark 전환, `flex_color_scheme` 기반 | P0 |

### 1.2 모델 관리

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-010 | Model Setup Screen | 로컬 스캔 → `.litertlm` 발견 시 등록 / 없으면 자동 다운로드 | P0 |
| F-011 | Model Progress UI | `LinearProgressIndicator` + % 텍스트, 홈 하단 고정 | P0 |
| F-012 | Model Selection | RAM ≥ 8GB + GPU 상위티어 → E4B, 그 외 → E2B | P1 |
| F-013 | Model Switch | Settings에서 E2B↔E4B 수동 전환 | P1 |

### 1.3 인증 (Auth)

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-020 | 비로그인 분석 허용 | 분석은 로그인 없이 가능, 저장 액션 시에만 Auth 유도 | P0 |
| F-021 | Google OAuth | `supabase.signInWithOAuth(google)` | P0 |
| F-022 | Kakao Auth | `kakao_flutter_sdk` → Edge Function `kakao-auth` → Supabase JWT | P0 |
| F-023 | 약관 동의 | Auth 화면 내 체크박스 (약관 + 개인정보처리방침) | P0 |
| F-024 | 로그아웃 / 회원탈퇴 | Settings에서 제공 | P1 |

### 1.4 관상 분석 (Face Reading)

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-030 | Camera Preview | 전면 카메라 즉시 프리뷰 | P0 |
| F-031 | Face Mesh Overlay | 468 landmarks 반투명 오버레이, 17개 핵심점 강조 | P0 |
| F-032 | Landmark Stability | 3초 안정 감지 후 "추출 완료" → [결과 보기] 버튼 활성 | P0 |
| F-033 | Feature Extraction | 17개 관상 특이점 + 파생 지표 5종 계산 | P0 |
| F-034 | Capture | 분석 시 캡처 1장 로컬 저장 | P0 |
| F-035 | Result Streaming | Gemma 장문 프롬프트(1000자+) 스트리밍 출력 | P0 |
| F-036 | RAG Integration | Edge Function `rag-search` → `physiognomy_kb` Top-5 chunk | P1 |
| F-037 | Result Sections | 이마/눈/코/입/턱/종합 6개 섹션 카드 | P0 |
| F-038 | Result Actions | [다시 보기] [저장] [공유] — 저장 시 비로그인이면 Auth 유도 | P0 |
| F-039 | Realtime Overlay Text | 5초마다 Gemma 실시간 피드백 (2~3문장, 단문 프롬프트) | P1 |

### 1.5 손금 분석 (Palm Reading)

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-040 | Palm Camera | 후면 카메라, MediaPipe HandLandmarker 21점 | P1 |
| F-041 | Hand Toggle | 왼손 / 오른손 토글 | P1 |
| F-042 | Palm Result | Face와 동일 파이프라인, `palmistry_kb` 사용 | P1 |

### 1.6 홈 화면

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-050 | Home Cards | 관상 보기 / 손금 보기 2개 카드 | P0 |
| F-051 | Login Banner | 비로그인 시 "저장하려면 로그인하세요" 배너 | P1 |
| F-052 | AppBar | Aura 로고 + 우측 메뉴(설정/약관/로그아웃) | P0 |

### 1.7 히스토리

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-060 | History List | 로그인 사용자 전용, `readings` 테이블 카드 리스트 | P1 |
| F-061 | History Item | 타입(face/palm) · 날짜 · 썸네일 | P1 |

### 1.8 설정

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-070 | Theme Toggle | Light/Dark | P0 |
| F-071 | Language Switch | 4개 언어 전환 | P0 |
| F-072 | Model Switch | E2B ↔ E4B 전환 | P1 |
| F-073 | Cache Clear | 로컬 캐시 삭제 | P1 |
| F-074 | Version Display | 앱 버전 표시 | P2 |

### 1.9 약관 / 개인정보처리방침

| ID | 기능 | 설명 | 우선순위 |
|---|---|---|---|
| F-080 | Privacy Policy | `assets/legal/{lang}/privacy.md` → `flutter_markdown` | P0 |
| F-081 | Terms of Service | `assets/legal/{lang}/terms.md` → `flutter_markdown` | P0 |

---

## 2. 아키텍처 모듈 분해

### 2.1 레이어 구조

```
Presentation (Riverpod 2.x + go_router)
  └─ features/
      ├─ splash/
      ├─ language_select/
      ├─ home/
      ├─ auth/
      ├─ face_reading/   ← camera_page + result_page
      ├─ palm_reading/
      ├─ history/
      ├─ settings/
      ├─ policy/
      └─ terms/

Domain (UseCase / Entity)
  └─ domain/
      ├─ entities/       ← Reading, Profile, LandmarkResult
      ├─ physiognomy/    ← landmark_index.dart (17점 상수)
      └─ usecases/       ← AnalyzeFaceUseCase, SaveReadingUseCase, ...

Data
  └─ data/
      ├─ supabase/       ← client, auth_repo, reading_repo
      ├─ gemma/          ← gemma_service, prompt_builder (2종)
      └─ mediapipe/      ← face_mesh_processor
```

### 2.2 신규 추가 의존성 (현재 pubspec.yaml 대비)

| 패키지 | 용도 | 버전 |
|---|---|---|
| `flutter_localizations` | 다국어 | SDK |
| `supabase_flutter` | 백엔드 | ^2.5.0 |
| `dio` | HTTP 클라이언트 | ^5.4.3 |
| `google_sign_in` | Google OAuth | ^6.2.1 |
| `kakao_flutter_sdk_user` | Kakao 인증 | ^1.9.0 |
| `flutter_riverpod` | 상태관리 | ^2.5.1 |
| `riverpod_annotation` | 코드젠 | ^2.3.5 |
| `go_router` | 라우팅 | ^14.0.0 |
| `flex_color_scheme` | 테마 | ^7.3.0 |
| `google_fonts` | 폰트 | ^6.2.0 |
| `flutter_markdown` | 마크다운 렌더 | ^0.7.0 |
| `lottie` | 애니메이션 | ^3.1.0 |
| `cached_network_image` | 이미지 캐시 | ^3.3.1 |
| `intl` | 국제화 | ^0.19.0 |
| `shared_preferences` | 로컬 저장 | ^2.2.3 |
| `permission_handler` | 권한 | ^11.3.1 |
| `path_provider` | 경로 | ^2.1.3 |
| `device_info_plus` | 기기 정보 | ^10.1.0 |
| `connectivity_plus` | 네트워크 상태 | ^6.0.3 |
| `uuid` | UUID 생성 | ^4.4.0 |
| `flutter_svg` | SVG 렌더 | ^2.0.10 |
| `build_runner` | 코드젠 | ^2.4.9 |
| `riverpod_generator` | Riverpod 코드젠 | ^2.4.0 |
| `freezed` | 불변 데이터 클래스 | ^2.5.2 |
| `json_serializable` | JSON 직렬화 | ^6.8.0 |

---

## 3. 카메라 → 분석 파이프라인 시퀀스

```
[Camera]
  YUV420 프레임 (15fps throttle, 66ms)
    ↓
  NV21 변환 (bytesPerPixel 기반 분기: interleaved/manual)
    ↓
  FaceMeshProcessor.processNv21()
    ↓
  468 landmarks 추출
    ↓
  17개 관상 특이점 + 파생 지표 5종 계산
    ↓  (3초 안정 시 → 버튼 활성)
  [결과 보기] 버튼 탭
    ↓
  [result_page]
  Edge Function rag-search → Top-5 chunk (physiognomy_kb)
    ↓
  fresh chat session (Gemma, 장문 프롬프트 + RAG 컨텍스트)
    ↓
  스트리밍 추론 → 섹션별 카드 (이마/눈/코/입/턱/종합)
    ↓
  [저장] → 비로그인이면 auth_page → Supabase Storage + readings insert
```

---

## 4. 수용 기준 (Acceptance Criteria)

### AC-001 스플래시 진입 속도
- **Given** 모델 캐시가 로컬에 존재할 때
- **When** 앱을 콜드 스타트하면
- **Then** 스플래시 → 홈 화면까지 ≤ 3초 (Android 9+ 중급 기기)

### AC-002 Face Mesh 안정성
- **Given** 정면 조명, 전면 카메라 활성화
- **When** 얼굴을 카메라에 위치시키면
- **Then** 15fps 이상 랜드마크 감지, 3초 연속 안정 후 버튼 활성화

### AC-003 결과 텍스트 품질
- **Given** Face Reading 분석 완료 시
- **When** Gemma 스트리밍이 완료되면
- **Then** 1000자 이상 · 이마/눈/코/입/턱/종합 6섹션 · 단정적 표현 없음

### AC-004 다국어 자연스러움
- **Given** KO/EN/JA/ZH 4개 언어 설정
- **When** 결과 화면을 각 언어로 확인하면
- **Then** 자연스러운 모국어 문장 (기계 번역 티 없음, locale별 프롬프트 사용)

### AC-005 비로그인 분석 허용
- **Given** 미로그인 상태
- **When** 관상/손금 분석 실행 시
- **Then** 분석 가능, [저장] 탭 시에만 Auth 화면으로 유도

### AC-006 Kakao 인증 플로우
- **Given** Kakao 앱 설치된 기기
- **When** Kakao 로그인 버튼 탭
- **Then** Kakao SDK → access token → Edge Function `kakao-auth` → Supabase JWT 발급 → 세션 유지

### AC-007 데이터 격리 (RLS)
- **Given** RLS가 `user_id = auth.uid()` 로 설정된 `readings` 테이블
- **When** 다른 사용자 ID로 저장된 레코드 조회 시도 시
- **Then** 0건 반환 (접근 불가)

### AC-008 Light/Dark 전환 무결성
- **Given** 앱 실행 중
- **When** Settings에서 테마 전환 시
- **Then** 모든 화면 즉시 전환, 깨지는 색상 없음

### AC-009 이미지 외부 전송 금지
- **Given** 사진 촬영 후
- **When** 저장 액션을 하지 않은 경우
- **Then** 이미지는 로컬에만 존재, Supabase Storage 미업로드

### AC-010 Play Console 권한 심사
- **Given** `CAMERA` 권한 사용
- **When** Play Console 심사 제출 시
- **Then** 권한 사유서(얼굴/손 분석 목적) 통과

---

## 5. 기존 코드 이관 계획

| 현재 위치 | 이관 위치 | 방법 |
|---|---|---|
| `lib/main.dart` | `lib/features/face_reading/` 분리 후 `lib/main.dart` 재구성 | `git mv` 후 리팩터 |
| `lib/model_config.dart` | `lib/features/model_setup/model_config.dart` | `git mv` |
| `lib/model_download_screen.dart` | `lib/features/model_setup/model_setup_screen.dart` | `git mv` |

> 원본 파일 삭제 금지. 반드시 `git mv` 사용.

---

## 6. 다음 단계 (Phase 2) 입력 사항

Phase 2 (`architecture-reviewer` + `api-architect`)에서 검토해야 할 항목:

1. `go_router` 라우트 테이블 설계 (11개 화면)
2. Riverpod Provider 트리 설계
3. `readings` 테이블 RLS 정책 SQL 초안
4. Supabase Edge Function 인터페이스 (kakao-auth, rag-search, embed-text)
5. `physiognomy_kb` / `palmistry_kb` vector(768) 임베딩 전략

---

*Phase 1 완료: 2026-04-12*

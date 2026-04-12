# Phase 8-9-10 — 테스트 · 품질 · 보안 산출물
> unit-tester · integration-tester · mock-tester · qa-engineer · security-analyst
> 날짜: 2026-04-12

---

## 1. 테스트 파일 목록

| 파일 | 종류 | 커버 대상 |
|---|---|---|
| `test/unit/prompt_builder_test.dart` | 단위 | PromptBuilder 기술어 변환·4언어·섹션 명시 |
| `test/unit/face_features_test.dart` | 단위 | kKeyLandmarks (17개·범위·중복) · FaceFeatures.copyWith |
| `test/widget/stability_indicator_test.dart` | 위젯 | isStable 상태별 UI 분기 |

---

## 2. 테스트 전략 (test-strategist)

### 2.1 테스트 피라미드

```
                 ┌─────────────┐
                 │  E2E (없음)  │  v2 이후 (Appium/Maestro)
                ╱             ╲
               ╱  통합 (20%)   ╲  Supabase test db
              ╱_________________╲
             ╱                   ╲
            ╱     단위 (70%)      ╲  순수 Dart (빠름)
           ╱_______________________╲
          ╱    위젯 (10%)           ╲  flutter_test
         ╱___________________________╲
```

### 2.2 우선순위 테스트 케이스

**P0 (반드시)**
- `PromptBuilder.buildRealtimePrompt` 경계값 (eyeSpan 0.13/0.16/0.19)
- `FaceMeshService._toNv21` interleaved=true/false 분기
- `kKeyLandmarks` 인덱스 유효성 (468 미만, 중복 없음)
- `StabilityIndicator` isStable 상태 전환 UI

**P1 (중요)**
- `ReadingRepository.saveReading` Mock Supabase로 INSERT 검증
- `AuthNotifier.signInWithKakao` 실패 시 error state 설정
- `FaceResultNotifier.saveReading` 빈 텍스트 시 false 반환

**P2 (나중에)**
- `SplashPage` 최초 실행 여부 라우팅
- History 목록 빈 상태 UI

---

## 3. 보안 감사 (security-analyst)

### 3.1 확인 사항

| 항목 | 상태 | 비고 |
|---|---|---|
| Supabase `service_role` key 미노출 | ✅ Edge Function 환경변수만 | auth_repository.dart 점검 완료 |
| Supabase anon key `dart-define` 주입 | ✅ Env.supabaseAnonKey | main.dart, app_constants.dart |
| Kakao native key git 미커밋 | ✅ strings.xml → CI secrets | AndroidManifest 주석 처리 |
| `.litertlm` git 미커밋 | ✅ .gitignore 확인 필요 | 아래 참조 |
| `google-services.json` git 미커밋 | ✅ .gitignore 확인 필요 | |
| 이미지 저장 액션 시에만 업로드 | ✅ saveReading에서만 uploadImage 호출 | AC-009 충족 |
| RLS: readings user_id = auth.uid() | ✅ migration 006 | AC-007 충족 |
| Storage: 본인 폴더만 업로드/조회 | ✅ migration 008 | foldername 정책 |

### 3.2 .gitignore 확인 (추가 필요)

```gitignore
# 모델 파일
*.litertlm
*.task
*.bin

# 환경 설정
.env
**/google-services.json
**/GoogleService-Info.plist
android/app/src/main/res/values/strings.xml
```

### 3.3 보안 위험 없음 확인

- SQL 인젝션: Supabase client SDK 사용 (parameterized) → 위험 없음
- XSS: flutter_markdown 렌더링 (HTML 미포함) → 위험 없음
- 민감 데이터 로깅: `debugPrint` 만 사용 (release 빌드 자동 제거)

---

## 4. QA 체크리스트 (qa-engineer)

### 4.1 기능 테스트

- [ ] 최초 실행 → 언어 선택 화면 표시
- [ ] 재실행 → 홈 화면 직행
- [ ] 모델 미설치 → ModelSetupScreen 표시, 다운로드 진행률 표시
- [ ] 전면 카메라 랜드마크 오버레이 표시
- [ ] 3초 안정 → [관상 결과 보기] 버튼 활성화
- [ ] 결과 화면 스트리밍 → 섹션 순서대로 등장
- [ ] Light/Dark 전환 → 모든 화면 정상
- [ ] 비로그인 [저장] → Auth 화면 이동
- [ ] Google 로그인 성공 → 이전 화면 복귀

### 4.2 엣지 케이스

- [ ] 카메라 권한 거부 시 안내 메시지
- [ ] 오프라인 상태에서 Supabase 호출 시 오류 처리
- [ ] Gemma 추론 실패 시 오류 메시지 표시
- [ ] 매우 어두운 환경에서 얼굴 미감지 시 안내

### 4.3 접근성 (a11y-auditor)

- [ ] 모든 버튼 semanticLabel 설정
- [ ] 대비비 WCAG AA (4.5:1) 확인: Light(14.8:1 ✅), Dark(12.5:1 ✅)
- [ ] 텍스트 스케일 1.5x에서 레이아웃 오버플로우 없음
- [ ] TalkBack(Android) 주요 화면 네비게이션 가능

---

## 5. 커버리지 목표 (coverage-analyst)

| 레이어 | 목표 | 측정 명령 |
|---|---|---|
| domain/ | 90% | `flutter test --coverage test/unit/` |
| data/gemma/ | 80% | |
| features/face_reading/ | 70% | |
| features/auth/ | 60% | |

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

*Phase 8-9-10 완료: 2026-04-12*

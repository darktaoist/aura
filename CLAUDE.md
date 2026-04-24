# Aura (gwansang) — Project Context for Claude Code

이 파일은 Claude Code 세션 시작 시 **자동 로드**된다. 모든 sub-agent는 이 파일과 아래 링크된 명세서를 따른다.

---

## 프로젝트 핵심 사실

- **표시 앱명**: Aura (아우라)
- **내부/패키지명**: `kr.co.taoist.gwansang.gwansang` (기존 gwansang 프로젝트 이어서 개발)
- **스택**: Flutter 3.38.9 / Dart 3.10.8 / Android minSdk 28
- **AI**: Gemma 4 E2B·E4B (`.litertlm`) via `flutter_gemma ^0.13.2`
- **Vision**: `mediapipe_face_mesh ^1.2.4` (FFI, xnnpack delegate, 468 landmarks)
- **백엔드**: Supabase (Auth · Postgres · Storage · pgvector · Edge Functions)
- **다국어**: KO / EN / JA / ZH / **테마**: Light / Dark

---

## 반드시 먼저 읽을 문서

@docs/spec.md

> 이 문서(`docs/spec.md`)가 **단일 소스 오브 트루스**다. 충돌이 있을 때 이 문서를 우선한다.

---

## 작업 원칙

1. `spec.md` §13 의 단계별 Sub-agent 매핑을 따르며, 에이전트 호출 시 이름을 명시한다.
2. 기존 `lib/main.dart`, `lib/model_config.dart`, `lib/model_download_screen.dart` 는 **삭제 금지**. `git mv` 로 `features/` 구조에 이관한다.
3. 새 의존성 추가 전 `pubspec.yaml` 현재 버전을 먼저 확인한다.
4. Gemma 시스템 프롬프트는 **2종 분리**: 실시간 오버레이용(2~3문장) vs 결과화면용(1000자+). 섞지 않는다.
5. 커밋 메시지 형식: `[<에이전트명>] <요약>` (예: `[app-developer] face camera page 리팩터링`)
6. Supabase `service_role` key는 클라이언트 코드에 절대 하드코딩하지 않는다. 환경변수·Edge Function 전용.
7. 사용자 얼굴·손 이미지는 저장 액션 시에만 Storage 업로드. 그 외엔 로컬 보관.
8. **모든 화면·위젯·출력물은 KO/EN/JA/ZH 4개 언어를 완전 지원**한다. 하드코딩된 문자열 금지. `AppLocalizations.of(context)!` + ARB 키 사용. 새 키 추가 시 4개 ARB 파일 모두 업데이트 후 `flutter gen-l10n` 실행.

---

## 사용 가능 리소스

- `.claude/agents/` — 35개 sub-agent (harness-100 기반)
- `.claude/skills/` — 24개 skill
- 에이전트 매핑표: `docs/spec.md` §13 참고

---

## 금지 사항

- Gemma `.litertlm` 모델 파일을 git 커밋 금지 (`.gitignore` 확인)
- `google-services.json`, `.env`, Kakao native key 커밋 금지
- 사용자 동의 없는 이미지 외부 전송 금지
- Addendum 이전 버전 / v1.0 명세서 / 원본 기초정보 문서 등 **폐기된 문서 내용을 근거로 결정하지 말 것**. `docs/spec.md` 만 참조.

---

## 세션 실행 가이드 (본인용 메모)

첫 프롬프트:
```
docs/spec.md 를 읽고, §13 매핑표에 따라 1단계 spec-parser 부터 순차 진행해줘.
각 단계의 산출물은 docs/phase_<N>_<에이전트>.md 로 기록하고,
단계가 끝날 때마다 커밋한 뒤 다음 단계로 넘어가줘.
```

긴 작업은 단계별로 `/clear` 후 새 세션. 복잡 설계는 Opus, 단순 구현은 Sonnet (`/model`).

# Phase 14 — store-manager 산출물
> Play Store 메타데이터 (4개 언어)
> 날짜: 2026-04-12

---

## 1. 앱 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 | Aura – AI 관상·손금 분석 |
| 패키지명 | `kr.co.taoist.gwansang.gwansang` |
| 카테고리 | 엔터테인먼트 / 라이프스타일 |
| 콘텐츠 등급 | 전체 이용가 |
| 개인정보처리방침 URL | (앱 내 링크) |

---

## 2. 스토어 등록 정보 (4개 언어)

### 한국어 (ko-KR)

**앱 이름 (30자)**: `Aura – AI 관상·손금 분석`

**짧은 설명 (80자)**:
> AI가 얼굴과 손을 읽어드립니다. 당신의 관상과 손금을 온디바이스 AI로 분석해보세요.

**전체 설명 (4000자 이내)**:
> Aura는 스마트폰 카메라와 온디바이스 AI(Gemma 4)로 당신의 관상과 손금을 분석해주는 앱입니다.
>
> 📱 **온디바이스 분석** — 인터넷 연결 없이도 실시간 분석. 얼굴 데이터는 저장 시에만 서버 전송.
>
> 🔮 **관상 분석** — MediaPipe 468개 랜드마크로 이마·눈·코·입·턱·종합 6개 섹션 상세 분석
>
> ✋ **손금 분석** — 손바닥 21개 특이점으로 생명선·감정선·지혜선 분석 (v1.1 예정)
>
> 📚 **전통 관상학 기반** — 동양 전통 관상학 지식베이스 + AI 해석으로 1000자 이상 상세 리포트
>
> 🌍 **4개 언어 지원** — 한국어·영어·일본어·중국어
>
> ⚡ **Light/Dark 테마** — 눈에 편한 화이트 베이스 또는 다크 모드

### English (en-US)

**App Name**: `Aura – AI Face & Palm Reading`

**Short Description**:
> Discover your destiny with on-device AI. Real-time face & palm analysis powered by Gemma 4.

**Full Description** (excerpt):
> Aura uses your smartphone camera and on-device AI (Gemma 4) to analyze your facial features and palm lines.
>
> 🔮 Face Reading – 6-section detailed report (Forehead, Eyes, Nose, Mouth, Chin, Overall)
> 📱 On-device AI – No internet required for analysis. Images only uploaded when you save.
> 🌍 4 Languages – Korean, English, Japanese, Chinese

### 日本語 (ja-JP)

**アプリ名**: `Aura – AI 観相・手相分析`

**短い説明**:
> オンデバイスAIで顔と手相を分析。インターネット不要でリアルタイム観相鑑定。

### 中文 (zh-CN)

**应用名称**: `Aura – AI面相手相分析`

**简短说明**:
> 用端侧AI分析面相和手相。无需网络即可实时鉴定，保护您的隐私。

---

## 3. 권한 사유서 (Play Console)

### CAMERA 권한
> 이 앱은 사용자의 얼굴과 손을 실시간으로 분석하기 위해 카메라 권한이 필요합니다. 카메라는 분석 목적으로만 사용되며, 사용자가 명시적으로 저장을 요청하는 경우에만 이미지가 서버에 업로드됩니다.

### WRITE_EXTERNAL_STORAGE (maxSdkVersion 28)
> Android 9 이하 기기에서 AI 모델 파일을 외부 저장소에 캐싱하기 위해 필요합니다.

---

## 4. 스크린샷 가이드

| 번호 | 화면 | 설명 |
|---|---|---|
| 1 | 홈 화면 | 관상·손금 카드 2개, 브랜드 그라데이션 |
| 2 | 카메라 화면 | 얼굴 랜드마크 오버레이 (17점 강조) |
| 3 | 결과 화면 | 섹션 카드 펼침 (이마 섹션 상세) |
| 4 | 결과 화면 | 종합 분석 1000자+ |
| 5 | 언어 선택 | 4개 언어 카드 |

---

*Phase 14 완료: 2026-04-12*

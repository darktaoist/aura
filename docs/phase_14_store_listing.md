# Phase 14 — 앱 스토어 배포 패키지 (store-manager)
> Aura (아우라) — AI 관상·손금 분석 앱  
> 패키지: `kr.co.taoist.gwansang.gwansang`  
> 작성일: 2026-04-12  
> 플랫폼: Google Play (1차) / App Store iOS (구조 유지)

---

## 목차

1. [앱 기본 정보](#1-앱-기본-정보)
2. [Google Play Store 등록 정보 (4개 언어)](#2-google-play-store-등록-정보)
3. [App Store iOS 등록 정보 (4개 언어)](#3-app-store-ios-등록-정보)
4. [스크린샷 시나리오 가이드](#4-스크린샷-시나리오-가이드)
5. [개인정보처리방침 체크리스트](#5-개인정보처리방침-체크리스트)
6. [Play Store 데이터 보안 양식](#6-play-store-데이터-보안-양식)
7. [심사 대응 체크리스트 및 리젝 예방](#7-심사-대응-체크리스트-및-리젝-예방)
8. [출시 전략](#8-출시-전략)

---

## 1. 앱 기본 정보

| 항목 | 값 |
|---|---|
| 표시 앱명 | **Aura (아우라)** |
| 내부/패키지명 | `kr.co.taoist.gwansang.gwansang` |
| 주 카테고리 | Entertainment (엔터테인먼트) |
| 부 카테고리 | Lifestyle (라이프스타일) |
| 연령 등급 (Play) | 모든 연령 — AI 생성 콘텐츠 미성년자 이용 가능, 오락 목적 명시 |
| 연령 등급 (App Store) | 4+ — 폭력·성인 콘텐츠 없음 |
| 개인정보처리방침 URL | `https://taoist.kr/aura/privacy` (앱 내 `/policy` 화면으로도 접근 가능) |
| 지원 언어 | 한국어 / 영어 / 일본어 / 중국어(간체) |
| 온디바이스 AI | Gemma 4 E2B · E4B (.litertlm) |
| 비전 엔진 | MediaPipe FaceMesh 468 landmarks, HandLandmarker 21 points |

---

## 2. Google Play Store 등록 정보

### 2-1. 한국어 (ko-KR)

**앱 이름 (50자 이내)**
```
Aura – AI 관상·손금 분석
```

**짧은 설명 (80자 이내)**
```
온디바이스 AI로 얼굴과 손을 읽다 — 인터넷 없이 관상·손금 분석, 사진은 내 폰 안에만
```
> 글자 수: 47자 (OK)

**전체 설명 (4000자 이내)**

```
당신의 얼굴과 손에는 어떤 이야기가 담겨 있을까요?

Aura(아우라)는 스마트폰 카메라와 최첨단 온디바이스 AI를 결합해 관상(觀相)과 손금을 풀이해 드리는 앱입니다. 분석은 전적으로 기기 내부에서 이루어지며, 사진은 사용자가 직접 저장을 선택할 때까지 단 한 장도 외부로 전송되지 않습니다.

── 핵심 기능 ──────────────────────────

▶ 관상 보기 (얼굴 분석)
스마트폰 카메라로 얼굴을 비추면 MediaPipe의 468개 랜드마크가 이마·눈·코·입·턱을 정밀 측정합니다. Gemma 4 AI가 전통 동양 관상학 지식을 바탕으로 1,000자 이상의 깊이 있는 해석을 제공합니다. 이마의 넓이, 눈 간격, 코의 비율, 좌우 대칭도 등 17가지 특이점을 종합 분석합니다.

▶ 손금 보기 (손 분석)
왼손/오른손을 카메라에 비추면 MediaPipe HandLandmarker가 21개 손 관절 위치를 추적합니다. 생명선·감정선·지혜선·운명선의 흐름과 특징을 AI가 해석해 드립니다.

▶ 완전한 온디바이스 AI
Gemma 4 E2B/E4B 모델이 기기에 설치되어 인터넷 없이도 분석이 가능합니다. 비행기 모드에서도 작동합니다.

▶ 철저한 프라이버시 보호
얼굴·손 이미지는 기기 내부에서만 처리됩니다. 사용자가 직접 '저장' 버튼을 누르기 전에는 서버로 전송되지 않습니다. 광고 없음 · 생체 데이터 판매 없음.

▶ 결과 히스토리
Google/Kakao 계정으로 로그인하면 과거 분석 결과를 저장하고 언제든지 다시 볼 수 있습니다. 로그인 없이도 분석 자체는 자유롭게 이용 가능합니다.

▶ 4개 언어 지원
한국어 · 영어 · 일본어 · 중국어(간체)로 분석 결과를 확인하세요.

▶ 라이트 / 다크 테마
눈에 편한 테마를 선택하세요.

── 이런 분께 추천합니다 ──────────────

• 동양 철학과 관상학에 관심 있는 분
• 자기 이해와 성찰의 도구를 찾는 분
• 사주·타로처럼 재미있는 엔터테인먼트를 즐기는 분
• 프라이버시를 중요하게 생각하는 분

── 주의 사항 ──────────────────────────

본 앱의 분석 결과는 오락 및 자기 성찰 목적으로만 제공됩니다. 과학적·의학적 진단이 아니며, 실제 의사결정의 근거로 사용하지 마세요.

Gemma 4 모델 파일(약 2.5GB~5GB)은 최초 실행 시 다운로드됩니다. Wi-Fi 환경에서 설치를 권장합니다.

── 권한 안내 ──────────────────────────

• 카메라: 관상·손금 분석을 위해 필수입니다.
• 인터넷: Gemma 모델 최초 다운로드 및 결과 저장(선택) 시 사용합니다.

개인정보처리방침: 앱 내 설정 > 개인정보처리방침에서 확인하세요.
```
> 글자 수: 약 940자 (4000자 이내, 여유 있음)

---

### 2-2. English (en-US)

**App Name (50 chars)**
```
Aura – AI Face & Palm Reading
```

**Short Description (80 chars)**
```
On-device AI reads your face & palm. No internet needed. Your photos stay private.
```
> Character count: 83 — trim if needed:
```
On-device AI face & palm reading. No internet. Photos never leave your device.
```
> Character count: 79 (OK)

**Full Description (4000 chars)**

```
What stories does your face hold? What do your palm lines reveal?

Aura combines your smartphone camera with cutting-edge on-device AI to interpret face reading (physiognomy) and palmistry. All analysis runs entirely on your device — your photos are never sent to any server unless you explicitly choose to save them.

── KEY FEATURES ────────────────────────

▶ Face Reading (Physiognomy)
Point your front camera at your face and MediaPipe's 468-point facial landmark engine precisely maps your forehead, eyes, nose, mouth, and chin. Gemma 4 AI draws on traditional Eastern physiognomy knowledge to deliver 1,000+ character in-depth readings covering 17 key facial markers: eye spacing, facial symmetry, nose proportions, and more. Results are organized into clear sections: Forehead · Eyes · Nose · Mouth · Chin · Overall.

▶ Palm Reading
Hold your left or right hand up to the camera. MediaPipe HandLandmarker tracks 21 joint positions in real time. Aura interprets your life line, heart line, head line, and fate line with AI-generated insight.

▶ Fully On-Device AI
Gemma 4 E2B or E4B (optimized for your device's RAM) runs locally — no cloud, no latency, no internet required after first setup. Works in airplane mode.

▶ Privacy First
Your face and palm images are processed entirely on-device. Nothing is uploaded until you tap Save. No ads. No biometric data sold. Ever.

▶ Reading History
Sign in with Google or Kakao to save readings to your private cloud and review them anytime. Analysis is always available without signing in.

▶ Four Languages
Korean · English · Japanese · Simplified Chinese — results delivered in the language you choose.

▶ Light & Dark Themes
Easy on the eyes, day or night.

── WHO IS AURA FOR? ────────────────────

• Anyone curious about Eastern philosophy and face reading
• People who enjoy self-reflection tools like astrology or tarot
• Privacy-conscious users who don't want their face data on a server
• Fortune-telling enthusiasts looking for a modern AI twist

── DISCLAIMER ──────────────────────────

Aura's readings are provided for entertainment and self-reflection purposes only. They do not constitute scientific, psychological, or medical advice and should not be used as the basis for real-world decisions.

── PERMISSIONS ─────────────────────────

• Camera: Required for face and palm analysis.
• Internet: Used once to download the Gemma AI model (~2.5–5 GB). Also used when you choose to save results to the cloud.

The Gemma 4 model file is downloaded on first launch. A Wi-Fi connection is strongly recommended.

Privacy Policy: Settings > Privacy Policy inside the app.
```
> Character count: ~1,600 (well within 4,000)

---

### 2-3. 日本語 (ja-JP)

**アプリ名 (50文字以内)**
```
Aura – AI 人相・手相 鑑定
```

**ショートの説明 (80文字以内)**
```
端末内AIで人相・手相を解析。ネット不要、写真は外部送信なし。プライバシー完全保護。
```
> 文字数: 43文字 (OK)

**詳細説明 (4000文字以内)**

```
あなたの顔には、どんな物語が刻まれているでしょうか。手のひらには、どんな可能性が眠っているでしょうか。

Aura(オーラ)は、スマートフォンのカメラと最先端のオンデバイスAIを組み合わせ、東洋の人相術・手相術をAIで解釈するアプリです。すべての解析はお使いの端末内で完結し、写真は明示的に「保存」を選択するまで外部へ一切送信されません。

── 主な機能 ──────────────────────────

▶ 人相を見る（顔分析）
フロントカメラで顔を映すと、MediaPipeの468点ランドマークがおでこ・目・鼻・口・顎を精密に計測します。Gemma 4 AIが伝統的な東洋人相学の知識をもとに、1,000文字以上の詳細な解釈を生成。目の間隔・顔の縦横比・鼻の位置・左右の対称性など17の特徴点を総合的に分析し、「おでこ・目・鼻・口・顎・総評」のセクションでお届けします。

▶ 手相を見る（手の分析）
左手・右手をカメラにかざすと、MediaPipe HandLandmarkerが21関節の位置をリアルタイムで追跡。生命線・感情線・知能線・運命線の流れをAIが解釈します。

▶ 完全オンデバイスAI
Gemma 4 E2B/E4Bモデルが端末にインストールされるため、初回セットアップ後はインターネット不要で解析できます。機内モードでも動作します。

▶ プライバシー最優先
顔・手のひら画像はすべて端末内で処理されます。「保存」ボタンを押すまでサーバーへの送信は行いません。広告なし・生体データの販売なし。

▶ 鑑定履歴
GoogleまたはKakaoアカウントでログインすると、過去の鑑定結果を保存していつでも見返すことができます。ログインなしでも鑑定は無制限に利用可能です。

▶ 4言語対応
韓国語・英語・日本語・中国語（簡体字）から好きな言語で結果を受け取れます。

▶ ライト / ダークテーマ
目に優しいテーマをお選びください。

── こんな方におすすめ ───────────────

• 東洋哲学・人相術・手相術に興味がある方
• 占いや自己分析ツールが好きな方
• 顔データをサーバーに送りたくないプライバシー重視の方
• 現代的なAI占いを楽しみたい方

── 免責事項 ──────────────────────────

本アプリの鑑定結果は、娯楽および自己内省を目的としたものです。科学的・医学的な診断ではなく、実際の意思決定の根拠としてご利用いただくものではありません。

── 権限について ───────────────────────

• カメラ: 人相・手相の解析に必須です。
• インターネット: Gemma AIモデルの初回ダウンロード（約2.5〜5GB）および結果の保存（任意）に使用します。

Gemmaモデルは初回起動時にダウンロードされます。Wi-Fi環境でのインストールを推奨します。

プライバシーポリシー: アプリ内「設定 > プライバシーポリシー」でご確認いただけます。
```

---

### 2-4. 中文简体 (zh-CN)

**应用名称 (50字以内)**
```
Aura – AI 面相·手相分析
```

**简短描述 (80字以内)**
```
设备端AI解读面相与手相，无需联网，照片绝不外传，隐私全程保护。
```
> 字数: 32字 (OK)

**完整描述 (4000字以内)**

```
你的面相藏着怎样的故事？手掌纹路又预示着什么？

Aura（光晕）将智能手机摄像头与尖端设备端AI相结合，以AI诠释传统东方面相学与手相学。所有分析完全在本地设备上运行——除非您主动选择保存，否则您的照片绝不会上传至任何服务器。

── 核心功能 ──────────────────────────

▶ 面相分析
打开前置摄像头，MediaPipe的468点面部特征点引擎将精准测量额头、眼睛、鼻子、嘴巴和下巴。Gemma 4 AI基于传统东方面相学知识，生成1,000字以上的深度解读，涵盖眼距、面部对称性、鼻梁比例等17项关键特征，以「额头·眼睛·鼻子·嘴巴·下巴·综合」分节呈现。

▶ 手相分析
将左手或右手对准摄像头，MediaPipe HandLandmarker实时追踪21个关节位置。AI将为您解读生命线、感情线、智慧线和命运线的走势与特征。

▶ 完全离线AI
Gemma 4 E2B/E4B模型安装在您的设备上，初次下载后无需联网即可分析。飞行模式下同样可用。

▶ 隐私优先
面部与手掌图像完全在设备端处理。在您点击「保存」之前，数据不会发送至服务器。无广告，不出售生物特征数据。

▶ 鉴定历史
使用Google或Kakao账号登录，即可保存历史分析记录，随时回顾。不登录同样可以无限次使用分析功能。

▶ 四种语言
韩语·英语·日语·简体中文——用您熟悉的语言查看分析结果。

▶ 亮色 / 暗色主题
随心切换，呵护双眼。

── 适合哪些用户 ──────────────────────

• 对东方哲学、面相学、手相学感兴趣的朋友
• 喜欢占卜和自我探索工具的用户
• 注重隐私、不愿将面部数据上传至服务器的用户
• 想体验现代AI占卜乐趣的用户

── 免责声明 ──────────────────────────

本应用的分析结果仅供娱乐和自我反思之用，不构成科学、心理或医学诊断，请勿将其作为现实决策的依据。

── 权限说明 ──────────────────────────

• 摄像头：面相与手相分析所必需。
• 网络：仅用于首次下载Gemma AI模型（约2.5~5GB）及用户主动选择保存结果时。

Gemma模型将在首次启动时下载，建议在Wi-Fi环境下安装。

隐私政策：可在应用内「设置 > 隐私政策」中查看。
```

---

## 3. App Store iOS 등록 정보

> iOS는 구조 유지 단계이므로 메타데이터를 선제적으로 준비합니다.  
> 1차 배포는 Google Play이며, iOS 제출 시 이 섹션을 그대로 사용합니다.

### 3-1. 한국어 (ko)

**앱 이름 (30자)**
```
Aura - AI 관상·손금 분석
```
> 22자 (OK)

**부제목 (30자)**
```
얼굴과 손이 말하는 나의 이야기
```
> 16자 (OK)

**프로모션 텍스트 (170자)**
```
온디바이스 Gemma 4 AI가 얼굴 468개 랜드마크와 손금을 분석합니다. 사진은 기기 밖으로 나가지 않습니다. 인터넷 없이도 완전한 관상·손금 풀이를 경험해보세요.
```
> 76자 (OK)

**설명 (4000자)**

```
당신의 얼굴과 손에는 어떤 이야기가 담겨 있을까요?

Aura(아우라)는 스마트폰 카메라와 최첨단 온디바이스 AI를 결합해 관상(觀相)과 손금을 풀이해 드리는 앱입니다. 분석은 전적으로 기기 내부에서 이루어지며, 사진은 사용자가 직접 저장을 선택할 때까지 단 한 장도 외부로 전송되지 않습니다.

[관상 보기]
스마트폰 전면 카메라로 얼굴을 비추면 MediaPipe의 468개 랜드마크가 이마·눈·코·입·턱을 정밀 측정합니다. Gemma 4 AI가 전통 동양 관상학 지식을 바탕으로 1,000자 이상의 깊이 있는 해석을 제공합니다. 이마의 넓이, 눈 간격, 코의 비율, 좌우 대칭도 등 17가지 특이점을 종합 분석합니다. 결과는 이마·눈·코·입·턱·종합 섹션으로 구성됩니다.

[손금 보기]
왼손 또는 오른손을 카메라에 비추면 MediaPipe HandLandmarker가 21개 손 관절 위치를 실시간으로 추적합니다. 생명선·감정선·지혜선·운명선의 흐름과 특징을 AI가 해석해 드립니다.

[완전한 온디바이스 AI]
Gemma 4 E2B 또는 E4B 모델(기기 성능에 따라 자동 선택)이 기기에 설치되어 인터넷 없이도 분석이 가능합니다. 비행기 모드에서도 동작합니다.

[철저한 프라이버시]
얼굴·손 이미지는 기기 내부에서만 처리됩니다. '저장' 버튼을 누르기 전에는 서버로 전송되지 않습니다. 광고 없음 · 생체 데이터 판매 없음.

[결과 히스토리]
Google/Kakao 계정으로 로그인하면 과거 분석 결과를 저장하고 언제든지 다시 볼 수 있습니다. 로그인 없이도 분석 자체는 자유롭게 이용 가능합니다.

[4개 언어 지원]
한국어 · 영어 · 일본어 · 중국어(간체)로 분석 결과를 확인하세요.

[라이트 / 다크 테마]
눈에 편한 테마를 선택하세요.

이런 분께 추천합니다:
• 동양 철학과 관상학에 관심 있는 분
• 자기 이해와 성찰의 도구를 찾는 분
• 사주·타로처럼 재미있는 엔터테인먼트를 즐기는 분
• 프라이버시를 중요하게 생각하는 분

주의: 본 앱의 분석 결과는 오락 및 자기 성찰 목적으로만 제공됩니다. 과학적·의학적 진단이 아닙니다.

Gemma 4 모델 파일(약 2.5GB~5GB)은 최초 실행 시 Wi-Fi로 다운로드됩니다.
```

**키워드 (100자, 쉼표로 구분)**
```
관상,손금,AI관상,AI손금,얼굴분석,관상보기,손금보기,운세,사주,점,얼굴운세,관상학,온디바이스AI
```
> 키워드 전략: 고빈도 검색어(관상, 손금, 운세, 사주) + 기능 키워드(AI관상, 얼굴분석) + 차별화(온디바이스AI)

---

### 3-2. English (en-US)

**App Name (30 chars)**
```
Aura - AI Face & Palm Reading
```
> 29 chars (OK)

**Subtitle (30 chars)**
```
Your face. Your story. On device.
```
> 33 chars — shorten:
```
On-Device AI Fortune Reading
```
> 29 chars (OK)

**Promotional Text (170 chars)**
```
Gemma 4 AI reads your face (468 landmarks) and palm lines on your device. No internet needed for analysis. Your photos never leave your phone without permission.
```
> 161 chars (OK)

**Description (4000 chars)**

```
What stories does your face hold? What do your palm lines reveal?

Aura combines your smartphone camera with cutting-edge on-device AI to interpret face reading (physiognomy) and palmistry. All analysis runs entirely on your device — your photos are never sent to any server unless you explicitly choose to save them.

FACE READING
Point your front camera at your face. MediaPipe's 468-point facial landmark engine precisely maps your forehead, eyes, nose, mouth, and chin in real time. Gemma 4 AI draws on traditional Eastern physiognomy knowledge to deliver 1,000+ character in-depth readings covering 17 key facial markers: eye spacing, facial symmetry, nose proportions, brow shape, and more. Results are organized into clear sections: Forehead · Eyes · Nose · Mouth · Chin · Overall Reading.

PALM READING
Hold your left or right hand to the camera. MediaPipe HandLandmarker tracks 21 joint positions in real time. Aura interprets your life line, heart line, head line, and fate line with AI-generated insight tailored to Eastern palmistry tradition.

FULLY ON-DEVICE AI
Gemma 4 E2B or E4B (selected automatically based on your device RAM) runs locally after the first download. No cloud, no latency, no internet required. Works in airplane mode.

PRIVACY FIRST
Your face and palm images are processed entirely on-device. Nothing is uploaded to any server until you tap Save. No ads. No biometric data sold. Your privacy is not a product.

READING HISTORY
Sign in with Google or Kakao to save readings to your private cloud and review them anytime. Analysis is always free and unlimited without signing in.

4 LANGUAGES
Korean · English · Japanese · Simplified Chinese

LIGHT & DARK THEMES
Comfortable reading experience day or night.

WHO IS AURA FOR?
• People curious about Eastern philosophy and face reading traditions
• Self-reflection enthusiasts who enjoy astrology, tarot, or personality tools
• Privacy-conscious users who don't want their face data on a server
• Anyone who wants a fresh, AI-powered take on fortune reading

DISCLAIMER
Aura's readings are provided for entertainment and self-reflection only. They do not constitute scientific, psychological, or medical advice. Do not use results as the basis for real-world decisions.

NOTES
The Gemma 4 AI model (~2.5–5 GB) is downloaded once on first launch. Wi-Fi is strongly recommended for the initial download. Subsequent use requires no internet.
```

**Keywords (100 chars, comma-separated)**
```
face reading,palm reading,physiognomy,palmistry,AI fortune,on-device AI,face analysis,fortune teller
```
> 100 chars exactly. Strategy: high-intent terms first (face reading, palm reading), category terms (fortune teller), differentiator (on-device AI)

---

### 3-3. 日本語 (ja)

**アプリ名 (30文字)**
```
Aura - AI人相・手相 鑑定
```
> 14文字 (OK)

**サブタイトル (30文字)**
```
端末内AIで顔と手のひらを読む
```
> 15文字 (OK)

**プロモーションテキスト (170文字)**
```
Gemma 4 AIが468点の顔ランドマークと手相線を端末内で解析。インターネット不要、写真は外部送信ゼロ。東洋の人相術と手相術をスマートフォンで体験。
```
> 68文字 (OK)

**説明 (4000文字)**

```
あなたの顔には、どんな物語が刻まれているでしょうか。手のひらには、どんな可能性が眠っているでしょうか。

Aura（オーラ）は、スマートフォンのカメラと最先端のオンデバイスAIを組み合わせ、東洋の人相術・手相術をAIで解釈するアプリです。すべての解析はお使いの端末内で完結し、写真は明示的に「保存」を選択するまで外部へ一切送信されません。

【人相を見る】
フロントカメラで顔を映すと、MediaPipeの468点ランドマークがおでこ・目・鼻・口・顎を精密に計測します。Gemma 4 AIが伝統的な東洋人相学の知識をもとに、1,000文字以上の詳細な解釈を生成。目の間隔・顔の縦横比・鼻の位置・左右の対称性など17の特徴点を総合的に分析し、「おでこ・目・鼻・口・顎・総評」の各セクションでお届けします。

【手相を見る】
左手・右手をカメラにかざすと、MediaPipe HandLandmarkerが21関節の位置をリアルタイムで追跡。生命線・感情線・知能線・運命線の流れと特徴をAIが解釈します。

【完全オンデバイスAI】
Gemma 4 E2B/E4Bモデル（端末のRAMに応じて自動選択）が端末にインストールされるため、初回ダウンロード後はインターネット不要で解析できます。機内モードでも動作します。

【プライバシー最優先】
顔・手のひら画像はすべて端末内で処理されます。「保存」ボタンを押すまでサーバーへの送信は行いません。広告なし・生体データの販売なし。

【鑑定履歴】
GoogleまたはKakaoアカウントでログインすると、過去の鑑定結果を保存していつでも見返すことができます。ログインなしでも鑑定は無制限に利用可能です。

【4言語対応】
韓国語・英語・日本語・中国語（簡体字）

【ライト / ダークテーマ】
目に優しいテーマをお選びください。

こんな方におすすめ：
• 東洋哲学・人相術・手相術に興味がある方
• 占い・自己分析ツールが好きな方
• 顔データをサーバーに送りたくないプライバシー重視の方
• AIを活用した現代的な占いを楽しみたい方

免責事項：
本アプリの鑑定結果は娯楽および自己内省を目的としたものです。科学的・医学的な診断ではなく、実際の意思決定の根拠としてご利用いただくものではありません。

初回起動時にGemma 4モデル（約2.5〜5GB）をダウンロードします。Wi-Fi環境でのご利用を推奨します。
```

**キーワード (100文字、カンマ区切り)**
```
人相,手相,AI占い,顔診断,手相占い,人相術,手相術,運勢,オンデバイスAI,プライバシー,顔分析,占いアプリ
```

---

### 3-4. 中文简体 (zh-Hans)

**应用名称 (30字)**
```
Aura - AI面相·手相分析
```
> 13字 (OK)

**副标题 (30字)**
```
设备端AI解读你的面相与命运
```
> 14字 (OK)

**宣传文本 (170字)**
```
Gemma 4 AI在您的设备上分析468个面部特征点与手掌纹路，全程无需联网，照片绝不外传。体验现代AI与传统东方面相学、手相学的完美融合。
```
> 62字 (OK)

**说明 (4000字)**

```
你的面相藏着怎样的故事？手掌纹路又预示着什么？

Aura（光晕）将智能手机摄像头与尖端设备端AI相结合，以AI诠释传统东方面相学与手相学。所有分析完全在本地设备上运行——除非您主动选择保存，否则您的照片绝不会上传至任何服务器。

【面相分析】
打开前置摄像头，MediaPipe的468点面部特征点引擎将精准测量额头、眼睛、鼻子、嘴巴和下巴。Gemma 4 AI基于传统东方面相学知识，生成1,000字以上的深度解读，涵盖眼距、面部对称性、鼻梁比例等17项关键特征，以「额头·眼睛·鼻子·嘴巴·下巴·综合」分节呈现。

【手相分析】
将左手或右手对准摄像头，MediaPipe HandLandmarker实时追踪21个关节位置，为您解读生命线、感情线、智慧线和命运线的走势与特征。

【完全离线AI】
Gemma 4 E2B/E4B模型（根据设备RAM自动选择）安装在本地设备上，首次下载后无需联网即可分析。飞行模式下同样可用。

【隐私优先】
面部与手掌图像完全在设备端处理。在您点击「保存」之前，数据不会发送至服务器。无广告，不出售生物特征数据。

【鉴定历史】
使用Google或Kakao账号登录，即可保存历史分析记录，随时回顾。不登录同样可以无限次使用分析功能。

【四种语言】
韩语·英语·日语·简体中文

【亮色 / 暗色主题】
随心切换，呵护双眼。

适合哪些用户：
• 对东方哲学、面相学、手相学感兴趣的朋友
• 喜欢占卜和自我探索工具的用户
• 注重隐私、不愿将面部数据上传至服务器的用户
• 想体验现代AI占卜乐趣的用户

免责声明：
本应用的分析结果仅供娱乐和自我反思之用，不构成科学、心理或医学诊断，请勿将其作为现实决策的依据。

Gemma模型（约2.5~5GB）将在首次启动时下载，建议在Wi-Fi环境下安装。
```

**关键词 (100字，逗号分隔)**
```
面相,手相,AI占卜,面相分析,手相占卜,面相学,手相学,运势,离线AI,隐私保护,人工智能算命,命运
```

---

## 4. 스크린샷 시나리오 가이드

> Google Play 요구: 최소 2장, 최대 8장 (16:9 또는 9:16)  
> App Store 요구: 최소 1장, 최대 10장 (기기별 사이즈셋)  
> 권장 해상도: 1080 × 2400 (Android) / 1290 × 2796 (iPhone 15 Pro Max)  
> 설계 원칙: "기능 소개"가 아닌 **가치 전달** — 사용자가 얻는 이득을 캡션에 담는다.

### 스크린샷 순서 및 시나리오

| # | 화면 | 한국어 캡션 | 영어 캡션 | 강조 포인트 | 비고 |
|---|---|---|---|---|---|
| 1 | **홈 화면** — 관상/손금 카드 2개, 미니멀 화이트 UI | "얼굴과 손이 말하는 당신의 이야기" | "Your face. Your story." | 앱의 첫인상, 브랜드 가치 | 다크 모드 버전도 제작 |
| 2 | **관상 카메라 화면** — 얼굴 위에 반투명 랜드마크 오버레이 | "468개 점이 읽는 당신의 관상" | "468 landmarks. One reading." | MediaPipe 기술력, 실시간성 | 랜드마크 오버레이 선명히 표시 |
| 3 | **관상 결과 화면** — 이마·눈·코·입·턱 섹션 카드 스크롤 | "1,000자 이상의 깊이 있는 분석" | "Deep reading. 1,000+ characters." | 결과 품질, 섹션 구성 | 실제 결과 텍스트 일부 노출 (면모 긍정적 문장 선택) |
| 4 | **손금 카메라 화면** — 손바닥 위에 HandLandmarker 오버레이 | "손금의 모든 선을 AI가 읽습니다" | "Every line, read by AI." | 손금 분석 기능 | 왼손/오른손 토글 UI 표시 |
| 5 | **손금 결과 화면** — 생명선·감정선·지혜선·운명선 카드 | "생명선부터 운명선까지 한눈에" | "Life. Heart. Head. Fate." | 4대 손금선 분석 | 손금선 시각화 아이콘 활용 |
| 6 | **온디바이스 AI 강조** — 모델 다운로드 완료 상태 + "인터넷 없이 분석 중" 토스트 | "인터넷 없이도 완벽한 분석" | "No internet. Full analysis." | 프라이버시 차별화 | 비행기 모드 아이콘 또는 Wi-Fi 끊긴 상태 화면 |
| 7 | **히스토리 화면** — 날짜·타입·썸네일 카드 리스트 | "나의 분석 기록을 언제든지" | "Your reading history, anytime." | 저장·재열람 기능 | 로그인 유도가 아닌 "기록 관리" 가치 강조 |
| 8 | **4개 언어 / 다크 모드** — 설정 화면 또는 언어 전환 비교 | "한·영·일·중, 내가 원하는 언어로" | "4 languages. Dark mode included." | 글로벌 접근성, 테마 | 언어 선택 카드 4개 나열 |

### 스크린샷 제작 지침

- **배경**: 화이트 베이스 + 부드러운 그라데이션 포인트(브랜드 컬러)
- **캡션 위치**: 상단 1/4 영역 — 텍스트가 UI를 가리지 않도록
- **폰트**: 앱과 동일한 Google Fonts 계열 (가독성 우선)
- **기기 프레임**: Pixel 8 Pro 프레임 사용 (Play), iPhone 15 Pro 프레임 사용 (App Store)
- **금지**: 실제 사용자 얼굴 노출 — 일러스트 또는 placeholder 얼굴 사용
- **금지**: 타 앱 비교, 경쟁사 언급, "최고" "1위" 등 검증 불가 수식어

---

## 5. 개인정보처리방침 체크리스트

> `assets/legal/{lang}/privacy.md` 파일 업데이트 기준  
> 현재 파일은 초안 수준 — 아래 항목으로 보완 필요

### 수집 데이터 상세

| 데이터 유형 | 수집 여부 | 수집 시점 | 사용 목적 | 보관 기간 | 사용자 연결 | 비고 |
|---|---|---|---|---|---|---|
| 얼굴 이미지 | 조건부 수집 | 사용자가 '저장' 선택 시에만 | 분석 결과와 함께 히스토리 저장 | 회원 탈퇴 시 즉시 삭제 | 연결됨 (user_id 기준) | 저장 전에는 기기 내 메모리에만 존재 |
| 손 이미지 | 조건부 수집 | 사용자가 '저장' 선택 시에만 | 분석 결과와 함께 히스토리 저장 | 회원 탈퇴 시 즉시 삭제 | 연결됨 | 동상 |
| 얼굴 랜드마크 좌표 (JSON) | 조건부 수집 | 저장 시 | 분석 재현, 히스토리 표시 | 회원 탈퇴 시 삭제 | 연결됨 | 생체인식 데이터 아님 — 수치 좌표 |
| 분석 결과 텍스트 | 조건부 수집 | 저장 시 | 히스토리 열람 | 회원 탈퇴 시 삭제 | 연결됨 | |
| 이메일 주소 | Google 로그인 시 수집 | OAuth 로그인 시 | 계정 식별 | 회원 탈퇴 시 삭제 | 연결됨 | Google/Kakao에서 전달 |
| 표시 이름 | Google/Kakao 로그인 시 | OAuth 로그인 시 | 앱 내 표시 | 회원 탈퇴 시 삭제 | 연결됨 | |
| 디바이스 정보 | 수집 안 함 | — | — | — | — | device_info_plus는 모델 선택에만 사용, 서버 미전송 |
| 사용 로그 / 분석 통계 | 수집 안 함 | — | — | — | — | 서드파티 애널리틱스 없음 |
| 광고 식별자 | 수집 안 함 | — | — | — | — | 광고 없음 |
| 위치 정보 | 수집 안 함 | — | — | — | — | |

### 개인정보처리방침 필수 기재 항목 체크

- [x] 수집 항목 및 수집 방법 명시
- [x] 이용 목적 명시
- [x] 보관 기간 명시
- [x] 제3자 제공 여부 (없음 — Supabase는 처리위탁, 제3자 제공 아님)
- [x] 처리위탁 명시: Supabase Inc. (미국, 저장소 위탁)
- [x] 국외 이전 명시: Supabase 서버 (AWS, 미국/유럽 리전)
- [x] 열람·정정·삭제 요청 방법 명시
- [x] 개인정보보호책임자 연락처
- [ ] **보완 필요**: 구체적인 위탁업체 목록 (Supabase, Google OAuth, Kakao OAuth)
- [ ] **보완 필요**: 만 14세 미만 이용 제한 명시 (Korea PIPA 요구)
- [ ] **보완 필요**: 영문/일문/중문 각 언어별 번역 완성도 확인

### 개인정보처리방침 URL 요구사항

- Google Play: 개발자 계정에 URL 등록 필수 (앱 페이지에 링크 표시)
- App Store: App Privacy 섹션 + 설명란 URL 필수
- 권장: `https://taoist.kr/aura/privacy` 또는 앱 내 `/policy` 화면으로 딥링크
- 방침 파일은 `assets/legal/{ko,en,ja,zh}/privacy.md` 에 최신 버전 유지

---

## 6. Play Store 데이터 보안 양식

> Google Play Console > 앱 콘텐츠 > 데이터 보안  
> 아래 항목을 기반으로 양식을 작성한다.

### 6-1. 앱이 데이터를 수집 또는 공유합니까?

**예** — 조건부 수집 (사용자가 저장을 선택한 경우에만)

### 6-2. 전송 중 데이터 암호화

**예** — HTTPS/TLS 1.2+ 사용 (Supabase 기본 제공)

### 6-3. 사용자가 데이터 삭제를 요청할 수 있습니까?

**예** — 앱 내 설정 > 회원 탈퇴로 즉시 삭제 가능

### 6-4. 수집 및 공유 데이터 상세

| 데이터 유형 (Play 분류) | 수집 여부 | 공유 여부 | 처리 목적 | 필수/선택 |
|---|---|---|---|---|
| 사진 및 동영상 > 사진 | 선택적 수집 (저장 시) | 공유 안 함 | 앱 기능 (히스토리 저장) | 선택 |
| 개인 정보 > 이름 | 선택적 수집 (로그인 시) | 공유 안 함 | 계정 관리 | 선택 |
| 개인 정보 > 이메일 주소 | 선택적 수집 (로그인 시) | 공유 안 함 | 계정 관리 | 선택 |
| 앱 활동 > 기타 사용자 생성 콘텐츠 | 선택적 수집 (저장 시) | 공유 안 함 | 앱 기능 (분석 결과 저장) | 선택 |
| 기기 또는 기타 ID | 수집 안 함 | — | — | — |
| 위치 | 수집 안 함 | — | — | — |
| 연락처 | 수집 안 함 | — | — | — |
| 금융 정보 | 수집 안 함 | — | — | — |
| 건강 및 피트니스 | 수집 안 함 | — | — | — |

> **주의**: 얼굴 랜드마크 좌표(468 points JSON)는 Google Play 분류상 "민감한 정보"에 해당할 수 있음.  
> 단순 수치 좌표로서 생체인식 식별에 사용되지 않음을 심사 메모에 명시할 것.

### 6-5. 데이터 보안 관행 요약 (스토어 표시용)

```
• 전송 중 데이터 암호화 (TLS)
• 사용자가 데이터 삭제를 요청할 수 있음
• 얼굴·손 이미지는 기기 외부로 전송되지 않음 (저장 선택 시 제외)
• 광고 목적으로 데이터를 사용하거나 판매하지 않음
• 제3자와 데이터를 공유하지 않음
```

---

## 7. 심사 대응 체크리스트 및 리젝 예방

### 7-1. Google Play 심사 체크리스트

#### 필수 기능 확인
- [ ] 모든 화면 정상 작동 (카메라 퍼미션 허용·거부 양쪽 플로우)
- [ ] 모델 다운로드 실패 시 재시도 UI 구현 및 에러 메시지 표시
- [ ] Gemma 모델 없는 상태에서 앱 크래시 없음
- [ ] 네트워크 없는 환경 (오프라인)에서 분석 기능 정상 작동
- [ ] 딥링크 `/policy`, `/terms` 정상 로드

#### 권한 정당성 (흔한 리젝 사유)
- [ ] **CAMERA 권한**: 매니페스트에 `android:required="true"` — 관상·손금 분석이 앱의 핵심 기능임을 심사 노트에 명시
- [ ] **INTERNET 권한**: 모델 다운로드 및 선택적 클라우드 저장에만 사용 — 데이터 수집이 아님을 명시
- [ ] `WRITE_EXTERNAL_STORAGE (maxSdk 28)`: Android 9 이하 지원, 최소 권한 원칙 준수
- [ ] 런타임 권한 요청 시 **명확한 사용 목적 설명 다이얼로그** 표시 필수

#### AI 생성 콘텐츠 관련
- [ ] 분석 결과 화면 하단에 면책 문구 표시: "본 결과는 오락 목적으로만 제공되며 전문적 조언을 대체하지 않습니다"
- [ ] AI 생성 콘텐츠임을 사용자가 알 수 있도록 UI에 표시
- [ ] Google Play 정책: "점술·운세" 앱 카테고리에서 허위 건강/의료 주장 금지 — 의학적 표현 제거 확인

#### 개인정보 관련
- [ ] 개인정보처리방침 URL 앱 스토어 페이지에 등록
- [ ] 데이터 보안 양식 (섹션 6) 작성 완료
- [ ] 얼굴 관련 데이터 처리 명확히 설명 (Prominent Disclosure 요구 가능성)
- [ ] 어린이 대상 앱이 아님 명시 (Gemma 콘텐츠 필터링 없음으로 전체 이용가 신중 검토 필요)

#### 콘텐츠 등급
- [ ] Play 앱 콘텐츠 등급 설문 완료
- [ ] "점술/미신" 항목 해당 — 일부 지역에서 등급 제한 가능 (일반적으로 전체 이용가)
- [ ] AI 생성 텍스트 필터링: 관상·손금 결과에 차별적 표현(인종·젠더 연관 체형 판단) 없음 확인 필수

### 7-2. App Store 심사 체크리스트 (사전 준비)

#### 기본 요건
- [ ] 앱이 완전히 기능함 — 더미 UI, 미완성 화면 없음
- [ ] 개인정보처리방침 URL 유효 (404 아님)
- [ ] App Privacy 양식 작성 완료
- [ ] 테스트 계정 정보 제공 (Google OAuth는 심사 계정 필요)

#### iOS 특이 항목
- [ ] `NSCameraUsageDescription` Info.plist에 명확한 문구 기재
  ```
  "관상과 손금 분석을 위해 카메라를 사용합니다. 촬영 이미지는 기기 내에서만 처리됩니다."
  ```
- [ ] ATT (App Tracking Transparency): 광고 미사용이므로 ATT 팝업 불필요 — 하지만 분석 목적 명시
- [ ] Sign in with Apple: iOS에서 Google/Kakao 소셜 로그인 제공 시 Sign in with Apple도 제공해야 함 (Guideline 4.8)
  > **중요**: iOS 1차 출시 전 Sign in with Apple 구현 필수. 현재 구현 없으면 리젝 확실.
- [ ] Guideline 1.4.3 (Medical Claims): 관상/손금이 의학적 진단을 제공한다는 표현 금지
- [ ] Guideline 3.2.2 (Unacceptable Business Model): 운세 앱 허용되나 실제 행동 유도 금지

#### 대형 파일 처리
- [ ] Gemma 모델 (~5GB)을 앱 바이너리에 포함하지 않고 런타임 다운로드 처리 — App Store 2GB 바이너리 제한 준수
- [ ] On-Demand Resource 또는 런타임 다운로드 방식 명확히

### 7-3. 주요 리젝 사유 및 대응 방안

| 리젝 사유 | 가능성 | 대응 방안 |
|---|---|---|
| 카메라 권한 목적 불명확 | 중 | `NSCameraUsageDescription` / 권한 다이얼로그에 "관상·손금 분석 전용" 명시 |
| Sign in with Apple 미구현 (iOS) | 높음 | iOS 출시 전 반드시 구현 (Guideline 4.8) |
| AI 결과에 의료/건강 주장 포함 | 중 | Gemma 프롬프트에서 건강 관련 단정 표현 금지, 면책 문구 필수 |
| 개인정보처리방침 URL 미등록 또는 404 | 높음 | 제출 전 URL 접근 가능 여부 반드시 확인 |
| 얼굴 데이터 처리 미고지 | 중 | Prominent Disclosure 다이얼로그 추가 ("얼굴 이미지는 기기 내에서만 처리됩니다") |
| 앱 완성도 미달 (모델 없는 상태 크래시) | 높음 | 모델 미설치 상태 처리 완성 후 제출 |
| 차별적 콘텐츠 (체형·외모 기반 판단) | 중 | Gemma 프롬프트에서 외모 가치판단 표현 필터링 |
| 결제 우회 (구독/인앱결제 미등록) | 낮음 | 현재 무료 앱 — 추후 인앱결제 추가 시 Play Billing 필수 |
| 대용량 초기 다운로드 미고지 | 중 | 스토어 설명 및 앱 내 "Wi-Fi 권장" 안내 명시 |

---

## 8. 출시 전략

### 8-1. 단계별 출시 계획

| 단계 | 시기 | 대상 | 목적 |
|---|---|---|---|
| 내부 테스트 | 출시 -4주 | 개발팀 5인 이내 | 핵심 기능 검증, 모델 다운로드 플로우 |
| 비공개 테스트 (Play) | 출시 -3주 | 테스터 20~50명 | 언어별 UI 검증, 분석 품질 피드백 |
| 공개 테스트 (Play) | 출시 -1주 | 전체 (opt-in) | 안정성 최종 확인 |
| 정식 출시 | D-Day | 전체 (한국 우선) | 초기 리뷰 수집 |
| 단계적 출시 | D+1 ~ D+7 | 10% → 50% → 100% | 크래시 모니터링 후 확대 |

### 8-2. 베타 테스트

- **Google Play 내부 테스트 트랙**: 최대 100명, 즉시 배포 가능
- **Google Play 비공개 테스트**: 20~2,000명, 출시 검토 없음
- **Google Play 공개 테스트**: opt-in 방식, 전체 공개

### 8-3. 버전 관리

| 버전 | 내용 |
|---|---|
| v1.0.0 | 관상 보기 (Face Reading) — Android |
| v1.1.0 | 손금 보기 (Palm Reading) 추가 |
| v1.2.0 | 히스토리, 로그인, 클라우드 저장 완성 |
| v2.0.0 | iOS 출시 + Sign in with Apple |
| v2.1.0 | 사주/타로 모듈 (예정) |

### 8-4. 출시 후 ASO 모니터링

- **KPI**: 검색 노출 순위 (관상, 손금, AI 관상), 전환율 (스토어 방문 → 설치), 평점 유지
- **A/B 테스트 후보**: 스크린샷 순서 (#1 vs #2 첫 번째), 짧은 설명 문구
- **리뷰 대응**: 1~2점 리뷰 48시간 내 공식 답변 — 모델 다운로드 오류, 분석 품질 피드백 우선
- **업데이트 주기**: 2주 단위 버그픽스, 4주 단위 기능 업데이트 — 업데이트 노트에 키워드 포함

---

## 부록: 개인정보처리방침 초안 (보완 버전)

> 이 초안을 `assets/legal/{ko}/privacy.md` 에 반영할 것.  
> 영/일/중 번역은 별도 진행.

```markdown
# 개인정보처리방침

**Aura** (이하 "앱" 또는 "서비스")는 사용자의 개인정보를 소중히 여기며, 개인정보보호법 및 관련 법령에 따라 아래와 같이 개인정보를 처리합니다.

---

## 1. 개인정보 수집 항목 및 수집 방법

| 수집 항목 | 수집 시점 | 수집 방법 |
|---|---|---|
| 얼굴 이미지, 손 이미지 | 사용자가 '저장' 기능을 명시적으로 선택한 경우에만 | 카메라 촬영 후 앱 내 업로드 |
| 얼굴 랜드마크 좌표 (수치 데이터) | '저장' 선택 시 | 앱 자동 생성 |
| 분석 결과 텍스트 | '저장' 선택 시 | AI 생성 |
| 이메일 주소, 표시 이름 | Google/Kakao 로그인 시 | OAuth 2.0 인증 |

**비로그인 분석**: 저장을 선택하지 않는 경우, 모든 이미지 및 분석 결과는 기기 메모리에서만 처리되며 앱 종료 시 삭제됩니다. 서버로 전송되지 않습니다.

---

## 2. 개인정보 이용 목적

- 관상·손금 분석 결과 저장 및 히스토리 제공
- 계정 식별 및 서비스 접근 인증
- 서비스 품질 유지 (오류 수정, 기능 개선)

---

## 3. 개인정보 보관 기간

- 회원 탈퇴 요청 시 즉시 삭제
- 저장된 분석 결과 및 이미지: 사용자 삭제 요청 또는 탈퇴 시 삭제
- 법령에 의한 보관 의무가 있는 경우 해당 기간 보관

---

## 4. 개인정보 처리 위탁

| 수탁업체 | 위탁 업무 | 위탁 데이터 |
|---|---|---|
| Supabase Inc. (미국) | 데이터 저장, 인증 서비스 | 계정 정보, 분석 결과, 이미지 |
| Google LLC | OAuth 인증 | 이메일, 표시 이름 |
| Kakao Corp. | OAuth 인증 | 이메일, 표시 이름 |

데이터는 AWS 서버(미국/유럽 리전)에 저장될 수 있습니다. 국외 이전 시 적절한 보호 조치가 적용됩니다.

---

## 5. 제3자 제공

사용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 광고 목적으로 데이터를 판매하지 않습니다.

---

## 6. 사용자 권리

사용자는 언제든지 다음 권리를 행사할 수 있습니다:
- 수집된 개인정보 열람 요청
- 개인정보 수정·삭제 요청
- 처리 정지 요청
- 앱 내 **설정 > 회원 탈퇴**로 즉시 삭제 가능

---

## 7. 만 14세 미만 아동

본 서비스는 만 14세 미만 아동을 대상으로 하지 않으며, 만 14세 미만 아동의 개인정보는 수집하지 않습니다.

---

## 8. 개인정보보호책임자

- 이메일: support@example.com
- 문의에 대해 72시간 이내 답변합니다.

---

## 9. 개정 이력

| 버전 | 일자 | 주요 변경 |
|---|---|---|
| v1.0 | 2026-04-12 | 최초 작성 |

---

본 방침은 2026년 4월 12일부터 시행됩니다.
```

---

*phase_14_store_listing.md — store-manager 산출물 완료*  
*작성: Claude Code (store-manager agent) · 2026-04-12*

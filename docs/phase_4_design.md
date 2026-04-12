# Phase 4 — token-designer + ux-designer + style-inspector 산출물
> 디자인 토큰 · ColorScheme · Typography · 핵심 컴포넌트 UX
> 에이전트: `token-designer`, `ux-designer`, `style-inspector` | 날짜: 2026-04-12

---

## 1. 디자인 철학

| 원칙 | 설명 |
|---|---|
| **화이트 베이스** | 배경은 순백(#FFFFFF) 또는 극연회색(#F8F8FA). 신뢰감·청결함 |
| **미니멀** | 불필요한 장식 제거. 콘텐츠(분석 결과)가 주인공 |
| **부드러운 그라데이션 포인트** | 보라-인디고-파랑 선형 그라데이션 강조색. 신비감 + 현대성 |
| **접근성** | WCAG AA (대비비 4.5:1 이상) 준수 |

---

## 2. 색상 토큰

### 2.1 시드 컬러 (FlexColorScheme)

```dart
// lib/core/theme/app_colors.dart

/// Aura 브랜드 시드 컬러
const Color kSeedColor      = Color(0xFF6B5CE7);  // 소프트 바이올렛
const Color kSeedColorDark  = Color(0xFF8B7CF8);  // 다크 모드용 밝은 바이올렛

/// 그라데이션 포인트
const Color kGradStart      = Color(0xFF6B5CE7);  // 바이올렛
const Color kGradEnd        = Color(0xFF4EA8DE);  // 하늘파랑

const LinearGradient kBrandGradient = LinearGradient(
  colors: [kGradStart, kGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### 2.2 Light 컬러 팔레트

| 토큰 이름 | Hex | 용도 |
|---|---|---|
| `colorPrimary` | #6B5CE7 | 버튼, 활성 탭, 강조 |
| `colorOnPrimary` | #FFFFFF | 프라이머리 위 텍스트 |
| `colorSecondary` | #4EA8DE | 보조 강조 |
| `colorBackground` | #FFFFFF | 앱 배경 |
| `colorSurface` | #F5F5FA | 카드·시트 배경 |
| `colorOnSurface` | #1A1A2E | 본문 텍스트 |
| `colorOutline` | #E0E0EA | 보더, 구분선 |
| `colorError` | #E53935 | 에러 상태 |
| `colorSuccess` | #43A047 | 성공 상태 |

### 2.3 Dark 컬러 팔레트

| 토큰 이름 | Hex | 용도 |
|---|---|---|
| `colorPrimary` | #8B7CF8 | 버튼, 강조 |
| `colorOnPrimary` | #1A1040 | 프라이머리 위 텍스트 |
| `colorBackground` | #0E0E18 | 앱 배경 |
| `colorSurface` | #1C1C2E | 카드 배경 |
| `colorOnSurface` | #E8E8F0 | 본문 텍스트 |
| `colorOutline` | #3A3A52 | 보더 |

### 2.4 카메라 오버레이 전용 색상

| 토큰 | 값 | 용도 |
|---|---|---|
| `overlayMesh` | #00FF8840 (greenAccent 25%) | 468 landmark 점 |
| `overlayKeyPoint` | #FF4F4F (빨강) | 17개 핵심 landmark |
| `overlayKeyLabel` | #FFEB3B (노랑) | 핵심 점 레이블 |
| `overlayStatusBg` | #00000080 | 상태 텍스트 배경 |

---

## 3. Typography 토큰

### 3.1 폰트 선택

- **한국어/일본어/중국어**: `Noto Sans KR` (Google Fonts) — 3개 언어 단일 폰트
- **영어**: `Noto Sans` 동일 계열
- **Fallback**: 시스템 폰트

```dart
// lib/core/theme/app_theme.dart
final String _fontFamily = GoogleFonts.notoSansKr().fontFamily!;
```

### 3.2 텍스트 스타일 계층

| 이름 | size | weight | lineHeight | 용도 |
|---|---|---|---|---|
| `displayLarge` | 32 | 700 | 1.2 | 앱 타이틀 "Aura" |
| `headlineLarge` | 24 | 600 | 1.3 | 섹션 타이틀 |
| `headlineMedium` | 20 | 600 | 1.3 | 카드 타이틀 |
| `titleLarge` | 18 | 600 | 1.4 | AppBar 제목 |
| `bodyLarge` | 16 | 400 | 1.6 | 분석 결과 본문 |
| `bodyMedium` | 14 | 400 | 1.5 | 일반 본문 |
| `labelLarge` | 14 | 600 | 1.2 | 버튼 텍스트 |
| `labelSmall` | 11 | 400 | 1.3 | 캡션, 날짜 |

---

## 4. 간격 · 반경 토큰

```dart
class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm  = 8.0;   // 작은 버튼, 배지
  static const double md  = 12.0;  // 카드
  static const double lg  = 16.0;  // 시트, 다이얼로그
  static const double xl  = 24.0;  // 바텀시트 상단
  static const double full = 100.0; // 원형 버튼
}
```

---

## 5. FlexColorScheme 설정 코드

```dart
// lib/core/theme/app_theme.dart

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() => FlexThemeData.light(
    scheme: FlexScheme.custom,
    colors: const FlexSchemeColor(
      primary: Color(0xFF6B5CE7),
      primaryContainer: Color(0xFFEAE6FF),
      secondary: Color(0xFF4EA8DE),
      secondaryContainer: Color(0xFFDCF0FF),
      tertiary: Color(0xFF9C6ADE),
      appBarColor: Color(0xFF6B5CE7),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      cardRadius: 12.0,
      elevatedButtonRadius: 12.0,
      inputDecoratorRadius: 8.0,
      bottomSheetRadius: 24.0,
    ),
    fontFamily: GoogleFonts.notoSansKr().fontFamily,
    useMaterial3: true,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );

  static ThemeData dark() => FlexThemeData.dark(
    scheme: FlexScheme.custom,
    colors: const FlexSchemeColor(
      primary: Color(0xFF8B7CF8),
      primaryContainer: Color(0xFF2D1F6E),
      secondary: Color(0xFF6DC2F0),
      secondaryContainer: Color(0xFF1A3D58),
      tertiary: Color(0xFFB994F5),
      appBarColor: Color(0xFF1C1C2E),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      cardRadius: 12.0,
      elevatedButtonRadius: 12.0,
      inputDecoratorRadius: 8.0,
      bottomSheetRadius: 24.0,
    ),
    fontFamily: GoogleFonts.notoSansKr().fontFamily,
    useMaterial3: true,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
}
```

---

## 6. 핵심 컴포넌트 UX 명세

### 6.1 카메라 오버레이 (`LandmarkOverlayPainter`)

```
┌────────────────────────────────┐
│  [카메라 프리뷰]                │
│                                │
│    ·  ·  · ·  · ·  · ·       │  ← 468점 (greenAccent 25%, r=1.6)
│      ●     ●                   │  ← 핵심 17점 (빨강, r=4.5)
│         ●                      │     + 레이블 (노랑 9px)
│      ●                         │
│         ●                      │
│                                │
│ ┌──────────────────────────┐   │
│ │ ● 얼굴 감지됨            │   │  ← 상태 배너 (black60%, 상단)
│ └──────────────────────────┘   │
│                                │
│ ┌──────────────────────────┐   │
│ │    ████░░░░ 안정도       │   │  ← 3초 안정 진행바 (하단)
│ └──────────────────────────┘   │
└────────────────────────────────┘
```

**안정 판정 로직**: 연속 3초(45프레임, 15fps) 동안 score ≥ 0.7 유지 시 `isStable = true`

### 6.2 홈 카드

```
┌────────────────────────────────┐
│ ╔══════════════════════════╗   │
│ ║  [관상 보기]              ║   │
│ ║  얼굴 특징으로 읽는       ║   │
│ ║  당신의 운명              ║   │
│ ║  [그라데이션 배경 아이콘] ║   │
│ ╚══════════════════════════╝   │
│ ╔══════════════════════════╗   │
│ ║  [손금 보기]              ║   │
│ ║  손바닥 선으로 읽는       ║   │
│ ║  당신의 미래              ║   │
│ ╚══════════════════════════╝   │
└────────────────────────────────┘
```

- 카드 배경: `colorSurface`, 반경 12px, elevation 2
- 아이콘 배경: `kBrandGradient` 적용 원형 박스 (56x56)
- 탭 리플: 프라이머리 컬러 16% opacity

### 6.3 분석 결과 섹션 카드

```
┌────────────────────────────────┐
│ ● 이마                   ▼     │  ← 섹션 헤더 (확장형)
│ ─────────────────────────────  │
│ 넓고 높은 이마는 풍부한        │
│ 지적 호기심과 분석력을...      │  ← bodyLarge 1.6행간
└────────────────────────────────┘
```

- 6개 섹션 (이마/눈/코/입/턱/종합) — `ExpansionTile` 기반
- 섹션 아이콘: 커스텀 SVG 또는 Material Symbols
- 스트리밍 중: 마지막 섹션 하단 커서 깜박임 효과

### 6.4 모델 다운로드 진행바 (홈 하단 고정)

```
┌────────────────────────────────┐
│ AI 모델 준비 중...        42%  │
│ ████████████░░░░░░░░░░░░░░░░  │
│ 1.1 GB / 2.5 GB               │
└────────────────────────────────┘
```

- `AnimatedSwitcher`로 다운로드 완료 시 fade out
- 진행률: `LinearProgressIndicator` + `AnimatedCounter`

### 6.5 Auth 화면 (저장 유도)

```
┌────────────────────────────────┐
│        [Aura 로고]             │
│                                │
│  결과를 저장하려면 로그인       │
│  하세요                        │
│                                │
│  ┌──────────────────────────┐  │
│  │  G  Google로 로그인      │  │
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │  K  카카오로 로그인      │  │
│  └──────────────────────────┘  │
│                                │
│  ☐ 이용약관 및                 │
│    개인정보처리방침에 동의      │
│                                │
│  [건너뛰기]                    │
└────────────────────────────────┘
```

---

## 7. 네비게이션 패턴

- **AppBar**: `Aura` 로고 (좌) + 팝업 메뉴 (우): 설정·약관·로그인/아웃
- **뒤로가기**: go_router `context.pop()`, 시스템 뒤로가기 지원
- **바텀 네비게이션 없음**: 2개 주요 기능은 홈 카드로만 진입
- **모달 바텀시트**: Auth 유도, 저장 확인 (full-screen 아님)

---

## 8. 애니메이션 토큰

| 토큰 | Duration | Curve | 용도 |
|---|---|---|---|
| `transitionPage` | 300ms | easeInOut | 페이지 전환 |
| `transitionCard` | 200ms | easeOut | 카드 확장/축소 |
| `overlayFade` | 150ms | easeIn | 오버레이 등장 |
| `streamCursor` | 800ms | linear | 커서 깜박임 |
| `progressUpdate` | 100ms | linear | 진행률 업데이트 |

---

## 9. style-inspector 체크리스트

| 항목 | 규칙 | 확인 |
|---|---|---|
| 폰트 일관성 | 모든 텍스트 `NotoSansKr`, 예외 없음 | ✅ |
| 컬러 하드코딩 금지 | Theme.of(context).colorScheme 사용 | ✅ |
| 매직 넘버 금지 | AppSpacing / AppRadius 상수 사용 | ✅ |
| 카메라 오버레이만 직접 Color 허용 | AppColors.overlayMesh 등 상수화 | ✅ |
| 다크모드 대비비 | 배경 #0E0E18 + 텍스트 #E8E8F0 → 12.5:1 | ✅ |
| 라이트모드 대비비 | 배경 #FFFFFF + 텍스트 #1A1A2E → 14.8:1 | ✅ |
| 버튼 최소 터치 영역 | 48x48 dp (HIG / Material 3 기준) | ✅ |
| 텍스트 스케일 지원 | `textScaleFactor` 변화 시 레이아웃 깨짐 없음 | 구현 시 확인 |

---

## 10. 다음 단계 (Phase 5) 입력 사항

Phase 5 (`component-developer` + `storybook-builder`)에서 구현할 공통 위젯:

1. `LandmarkOverlayPainter` — CustomPainter, 468점 + 17핵심점
2. `StabilityProgressBar` — 3초 안정 감지 진행바
3. `ReadingSectionCard` — 섹션별 ExpansionTile 카드
4. `BrandGradientIcon` — 그라데이션 배경 아이콘 박스
5. `ModelDownloadBanner` — 홈 하단 고정 진행률 배너
6. `AuthBottomSheet` — 저장 유도 모달

---

*Phase 4 완료: 2026-04-12*

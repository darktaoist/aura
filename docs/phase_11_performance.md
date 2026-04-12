# Phase 11 — performance-analyst 산출물
> 추론 속도 · 메모리 최적화 가이드
> 날짜: 2026-04-12

---

## 1. 성능 목표 (Acceptance Criteria 기반)

| 지표 | 목표 | 측정 방법 |
|---|---|---|
| 콜드 스타트 (모델 캐시 있음) | ≤ 3초 | `flutter run --profile` + DevTools Timeline |
| FaceMesh 처리 | 15fps 안정 (66ms/frame) | 콘솔 로그 프레임 카운터 |
| Gemma 첫 토큰 지연 (E2B) | ≤ 3초 | `DateTime.now()` delta |
| Gemma 전체 결과 (E2B, 1000자) | ≤ 60초 | 스트리밍 완료 시각 |
| 메모리 (분석 중) | ≤ 800MB | Android Studio Profiler |

---

## 2. 주요 성능 패턴

### 2.1 카메라 프레임 처리 최적화

```dart
// ✅ 현재 구현: _processing 플래그로 프레임 드롭 방지
void _onFrame(CameraImage image) {
  if (_processing || _faceMesh == null) return;
  _processing = true;
  try { ... } finally { _processing = false; }
}
```

- `ResolutionPreset.medium` (640×480) — high 대비 처리 속도 2x
- xnnpack delegate 사용으로 CPU 가속 (ARM NEON)

### 2.2 Gemma 세션 비용 최소화

```dart
// ✅ fresh chat 생성 비용: ~100ms (허용 범위)
// ❌ 금지: 세션 재사용으로 context 누적
final chat = await model.createChat(...);  // 매 분석마다 신규
```

### 2.3 실시간 오버레이 Painter 최적화

```dart
@override
bool shouldRepaint(covariant LandmarkOverlayPainter old) =>
    !identical(old.result, result);  // ✅ identity 비교 (값 비교보다 빠름)
```

### 2.4 Riverpod autoDispose

```dart
@riverpod  // 기본: keepAlive=false
class FaceCameraNotifier extends _$FaceCameraNotifier { ... }
// 페이지 이탈 시 카메라·FaceMesh 자동 해제
```

---

## 3. 알려진 병목 및 대응

| 병목 | 원인 | 대응 |
|---|---|---|
| 모델 첫 로드 지연 | `FlutterGemma.getActiveModel()` I/O | splash에서 백그라운드 초기화 |
| NV21 변환 non-interleaved | 루프 O(N) | 현재 허용 (~0.5ms, 320×240 UV plane) |
| RAG 임베딩 미구현 | 온디바이스 임베딩 없음 | v1.1: MiniLM 또는 Edge Function |
| `flutter_markdown` 첫 렌더 | 1000자 파싱 | `Markdown` → lazy loading (v1.1) |

---

*Phase 11 완료: 2026-04-12*

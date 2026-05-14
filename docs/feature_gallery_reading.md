# Feature Spec: 갤러리 사진으로 관상/손금 분석

> 상태: 구현 전 (Draft)
> 관련 화면: `/face/camera`, `/palm/camera`
> 관련 스팩: `docs/spec.md` §8.5 Face Reading, §8.6 Palm Reading

---

## 1. 개요

현재 실시간 카메라 스트림만 지원하는 관상·손금 분석에, **갤러리(앨범)에서 사진을 선택해 분석**하는 경로를 추가한다.
기존 랜드마크 추출 → Gemma 분석 파이프라인을 그대로 재사용하며, 입력 소스만 카메라 프레임에서 파일 경로로 교체한다.

---

## 2. 사용자 시나리오

```
[관상 보기] 탭
  → /face/camera 진입
  → 하단에 [갤러리에서 선택] 버튼 노출
  → 갤러리 열림 → 사진 선택
  → 랜드마크 추출 (정적 이미지)
    → 성공: /face/result 로 이동 (카메라 결과와 동일)
    → 실패 (얼굴 미감지): 스낵바 → 다시 선택 유도
```

손금 분석(`/palm/camera`)도 동일 구조로 적용.

---

## 3. UI/UX 명세

### 3.1 카메라 화면 (`face_camera_page.dart`)

**현재 레이아웃 (bottom 영역)**
```
[안정화 인디케이터]         ← bottom: 116
[관상 결과 보기 버튼]        ← bottom: 40
```

**변경 후**
```
[안정화 인디케이터]          ← bottom: 164 (위로 48 올림)
[관상 결과 보기 버튼]        ← bottom: 88  (위로 48 올림)
[갤러리에서 선택 버튼]       ← bottom: 36  (신규)
```

- `[갤러리에서 선택]`: `TextButton.icon(Icons.photo_library_outlined)` — 항상 활성
- `[관상 결과 보기]`: 기존과 동일 (안정화 완료 시만 활성)
- 갤러리 처리 중 로딩 표시: 버튼 위치에 `CircularProgressIndicator` 인라인 교체

### 3.2 갤러리 선택 중 카메라 동작

갤러리 피커가 열리는 동안 카메라 스트림은 **일시 중지** (배터리/성능).
피커 닫힘 후 재개.

---

## 4. 기술 구현

### 4.1 패키지 추가

```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.1.2
```

### 4.2 Android 권한

`android/app/src/main/AndroidManifest.xml`

```xml
<!-- 기존: API 32 이하 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>

<!-- 신규: API 33+ (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

`permission_handler`는 이미 의존성에 존재 — 런타임 권한 요청에 활용.

### 4.3 FaceMeshService — 정적 이미지 처리 메서드 추가

```dart
// lib/data/mlkit/face_mesh_service.dart

/// 파일 경로(갤러리 사진) → FaceLandmarkResult?
Future<FaceLandmarkResult?> processFile(String imagePath) async {
  final detector = _detector;
  if (detector == null) return null;

  try {
    // ML Kit가 EXIF 방향 자동 처리 → rotation0deg 고정
    final inputImage = InputImage.fromFilePath(imagePath);
    final List<FaceMesh> meshes = await detector.processImage(inputImage);
    if (meshes.isEmpty) return null;

    final mesh = meshes.first;
    final rawPoints = mesh.points;
    if (rawPoints.isEmpty) return null;

    // 이미지 실제 크기 취득 (좌표 정규화에 필요)
    final imageSize = inputImage.metadata?.size;
    final double w = imageSize?.width ?? _inferWidth(rawPoints);
    final double h = imageSize?.height ?? _inferHeight(rawPoints);

    final ordered = List<LandmarkPoint>.generate(
      468,
      (_) => const LandmarkPoint(x: 0.5, y: 0.5, z: 0.0),
    );

    for (final p in rawPoints) {
      final idx = p.index;
      if (idx < 0 || idx >= 468) continue;
      ordered[idx] = LandmarkPoint(
        x: (p.x / w).clamp(0.0, 1.0),
        y: (p.y / h).clamp(0.0, 1.0),
        z: p.z,
      );
    }

    return FaceLandmarkResult(
      landmarks: ordered,
      score: 1.0,
      features: _extractFeatures(ordered),
      frameWidth: w.toInt(),
      frameHeight: h.toInt(),
    );
  } catch (e, st) {
    debugPrint('[FaceMeshService] processFile error: $e\n$st');
    return null;
  }
}
```

> 좌표 정규화: `InputImage.fromFilePath`는 metadata가 없을 수 있으므로, rawPoints의 max 값으로 fallback 추론하거나 `dart:ui` Image 디코딩으로 크기를 별도 취득.

### 4.4 FaceCameraPage — 갤러리 선택 핸들러

```dart
Future<void> _pickFromGallery() async {
  // 카메라 스트림 일시 중지
  try { await _camera?.stopImageStream(); } catch (_) {}

  setState(() => _isGalleryLoading = true);

  try {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null || !mounted) return;

    final result = await _faceMesh?.processFile(file.path);

    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noFaceDetected)),
      );
      return;
    }

    await _goToResult(result);
  } finally {
    if (mounted) setState(() => _isGalleryLoading = false);
    // 카메라 스트림 재개 (결과 화면으로 이동하지 않은 경우)
    if (!_navigating) {
      try { await _camera?.startImageStream(_onFrame); } catch (_) {}
    }
  }
}
```

---

## 5. 다국어 (i18n)

`lib/core/l10n/app_{ko,en,ja,zh}.arb` 에 아래 키 추가 후 `flutter gen-l10n` 실행.

| ARB 키 | KO | EN | JA | ZH |
|---|---|---|---|---|
| `selectFromGallery` | 갤러리에서 선택 | Select from Gallery | ギャラリーから選択 | 从相册选择 |
| `noFaceDetected` | 얼굴을 감지하지 못했습니다. 다른 사진을 선택해 주세요. | No face detected. Please select another photo. | 顔を検出できませんでした。別の写真を選んでください。 | 未检测到人脸，请选择其他照片。 |
| `galleryPermissionRequired` | 사진 접근 권한이 필요합니다. | Photo library access is required. | 写真へのアクセス権限が必要です。 | 需要相册访问权限。 |

> `noFaceDetected`는 손금 감지 실패(`noPalmDetected`)와 별도 키로 분리.

---

## 6. 손금 분석 적용

`HandLandmarkService`에도 동일하게 `processFile(String imagePath)` 추가.
`palm_camera_page.dart`에 동일 패턴으로 갤러리 버튼 추가.

손금은 왼손/오른손 토글이 있으므로, 갤러리 선택 후 "왼손/오른손?" 바텀시트를 먼저 표시한다.

---

## 7. 에러 케이스

| 상황 | 처리 |
|---|---|
| 권한 거부 | 스낵바 + [설정 열기] 액션 |
| 얼굴/손 미감지 | 스낵바 → 다시 선택 가능 |
| 파일 읽기 실패 | 스낵바 (일반 오류 메시지) |
| FaceMeshService 미초기화 | 갤러리 버튼 비활성 처리 |

---

## 8. 구현 순서 (체크리스트)

- [ ] `image_picker ^1.1.2` pubspec.yaml 추가
- [ ] `READ_MEDIA_IMAGES` 권한 AndroidManifest 추가
- [ ] `FaceMeshService.processFile()` 구현
- [ ] `HandLandmarkService.processFile()` 구현
- [ ] ARB 4개 언어 키 추가 + `flutter gen-l10n`
- [ ] `FaceCameraPage` UI 레이아웃 조정 + 갤러리 핸들러 연결
- [ ] `PalmCameraPage` 동일 작업 + 손 선택 바텀시트
- [ ] 동작 확인: 사진 선택 → 결과 화면 진입
- [ ] 동작 확인: 얼굴 없는 사진 → 스낵바
- [ ] 동작 확인: 권한 거부 → 설정 안내

---

## 9. 범위 외 (이번 구현에 포함하지 않음)

- 갤러리 사진의 Storage 저장 (저장 버튼 액션은 기존 결과화면 로직 그대로)
- 사진 크롭/보정 UI
- 여러 장 선택 (1회 1장)
- iOS 지원 (Android 1차 완성 후 동일 패턴 적용)

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image/image.dart' as img_pkg;

import '../../domain/entities/landmark_result.dart';
import '../../domain/physiognomy/landmark_index.dart';

/// MLKit FaceMesh 서비스
///
/// 좌표 변환 원칙:
///   InputImageMetadata.rotation = sensorOrientation (270° for front camera on LG Q920N)
///   MLKit 가 내부적으로 회전 후 detection → 반환 좌표는 회전된 portrait 공간
///   point.x ∈ [0, image.height],  point.y ∈ [0, image.width]  (rotation 90°/270°)
///   정규화: nx = x / image.height,  ny = y / image.width
///   전면카메라 좌우 반전: nx = 1 - nx
class FaceMeshService {
  FaceMeshService._();

  FaceMeshDetector? _detector;
  bool get isReady => _detector != null;

  bool _coordsLogged = false;

  static Future<FaceMeshService> create() async {
    final svc = FaceMeshService._();
    svc._detector = FaceMeshDetector(
      option: FaceMeshDetectorOptions.faceMesh,
    );
    return svc;
  }

  /// CameraImage → FaceLandmarkResult?  (async — MLKit FFI)
  Future<FaceLandmarkResult?> process(
      CameraImage image, CameraDescription camera) async {
    final detector = _detector;
    if (detector == null) return null;

    try {
      final inputImage = _buildInputImage(image, camera);
      if (inputImage == null) return null;

      final List<FaceMesh> meshes = await detector.processImage(inputImage);
      if (meshes.isEmpty) {
        debugPrint('[FaceMeshService] no face detected');
        return null;
      }

      final mesh = meshes.first;
      final rawPoints = mesh.points; // List<FaceMeshPoint> — may be unordered

      final isFront = camera.lensDirection == CameraLensDirection.front;
      final bool isTransposed =
          camera.sensorOrientation == 90 || camera.sensorOrientation == 270;

      // rotation 90°/270° 일 때 반환 좌표는 portrait(display) 공간
      //   x ∈ [0, image.height],  y ∈ [0, image.width]
      final double xScale =
          isTransposed ? image.height.toDouble() : image.width.toDouble();
      final double yScale =
          isTransposed ? image.width.toDouble() : image.height.toDouble();
      final int dispWidth  = isTransposed ? image.height : image.width;
      final int dispHeight = isTransposed ? image.width  : image.height;

      // 468개 슬롯 초기화 후 index 기반 채우기
      final ordered = List<LandmarkPoint>.generate(
        468,
        (_) => const LandmarkPoint(x: 0.5, y: 0.5, z: 0.0),
      );

      for (final p in rawPoints) {
        final idx = p.index;
        if (idx < 0 || idx >= 468) continue;

        double nx = p.x / xScale;
        double ny = p.y / yScale;
        if (isFront) nx = 1.0 - nx; // selfie 카메라 좌우 반전

        ordered[idx] = LandmarkPoint(
          x: nx.clamp(0.0, 1.0),
          y: ny.clamp(0.0, 1.0),
          z: p.z,
        );
      }

      // 최초 1회: 좌표 범위 확인 로그
      if (!_coordsLogged && rawPoints.isNotEmpty) {
        _coordsLogged = true;
        final p0 = rawPoints.first;
        debugPrint('[FaceMeshService] ── 첫 포인트 원시값 ──\n'
            '  image: ${image.width}×${image.height} '
            'sensorOri=${camera.sensorOrientation} isFront=$isFront\n'
            '  p[0]: index=${p0.index} x=${p0.x.toStringAsFixed(1)} '
            'y=${p0.y.toStringAsFixed(1)} z=${p0.z.toStringAsFixed(3)}\n'
            '  xScale=$xScale yScale=$yScale\n'
            '  norm_x=${(p0.x/xScale).toStringAsFixed(3)} '
            'norm_y=${(p0.y/yScale).toStringAsFixed(3)}\n'
            '  dispW=$dispWidth dispH=$dispHeight '
            'totalPoints=${rawPoints.length}');
      }

      return FaceLandmarkResult(
        landmarks: ordered,
        score: 1.0, // MLKit: 감지 성공 = 1.0
        features: _extractFeatures(ordered),
        frameWidth: dispWidth,
        frameHeight: dispHeight,
      );
    } catch (e, st) {
      debugPrint('[FaceMeshService] process error: $e\n$st');
      return null;
    }
  }

  // ── 정적 이미지(갤러리) 처리 ──────────────────────────────────────────────

  /// 갤러리 사진 파일 경로 → FaceLandmarkResult?
  ///
  /// ML Kit fromFilePath: 파일을 직접 읽고 EXIF 방향을 내부에서 처리.
  /// 반환 좌표는 display(EXIF 보정) 공간의 절대 픽셀 좌표.
  /// image 패키지로 동일한 display 크기를 구해 정규화.
  Future<FaceLandmarkResult?> processFile(String imagePath) async {
    final detector = _detector;
    if (detector == null) return null;

    try {
      // display 크기 확보 (EXIF 보정 적용 — ML Kit 반환 좌표계와 동일)
      final bytes = await File(imagePath).readAsBytes();
      final raw = img_pkg.decodeImage(bytes);
      if (raw == null) return null;
      final oriented = img_pkg.bakeOrientation(raw);
      final w = oriented.width;
      final h = oriented.height;

      // ML Kit이 파일을 직접 디코딩 + EXIF 처리
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<FaceMesh> meshes = await detector.processImage(inputImage);
      if (meshes.isEmpty) {
        debugPrint('[FaceMeshService] processFile: no face detected (${w}x$h)');
        return null;
      }

      final mesh = meshes.first;
      final rawPoints = mesh.points;
      if (rawPoints.isEmpty) return null;

      debugPrint('[FaceMeshService] processFile: ${rawPoints.length} points, '
          'img=${w}x$h  p0=(${rawPoints.first.x.toStringAsFixed(1)},'
          '${rawPoints.first.y.toStringAsFixed(1)})');

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
        frameWidth: w,
        frameHeight: h,
      );
    } catch (e, st) {
      debugPrint('[FaceMeshService] processFile error: $e\n$st');
      return null;
    }
  }

  // ── InputImage 생성 ───────────────────────────────────────────────────────
  //
  // YUV_420_888 → NV21 수동 변환 후 InputImage.fromBytes 로 전달.
  // MLKit Android 는 NV21 을 네이티브로 처리하므로 가장 안정적.
  // stride 패딩 보정 로직은 MediaPipe 래퍼에서 검증된 것과 동일.
  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    try {
      final nv21 = _toNv21(image);
      final rotation = _sensorToRotation(camera.sensorOrientation);

      return InputImage.fromBytes(
        bytes: nv21,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width, // NV21 은 padding 없이 tight-packed
        ),
      );
    } catch (e) {
      debugPrint('[FaceMeshService] InputImage build error: $e');
      return null;
    }
  }

  // ── YUV_420_888 → NV21 ────────────────────────────────────────────────────
  Uint8List _toNv21(CameraImage image) {
    final w = image.width;
    final h = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final nv21 = Uint8List(w * h + (w * h) ~/ 2);
    int pos = 0;

    // ── Y 평면 (행 stride 제거) ──
    for (int row = 0; row < h; row++) {
      nv21.setRange(pos, pos + w, yPlane.bytes, row * yPlane.bytesPerRow);
      pos += w;
    }

    // ── VU 인터리브 (NV21 = V 먼저) ──
    final uvH = h ~/ 2;
    final uvW = w ~/ 2;
    final int vPs = vPlane.bytesPerPixel ?? 1;
    final int uPs = uPlane.bytesPerPixel ?? 1;

    // LG Q920N 처럼 실제 버퍼가 tight-packed 인데 bytesPerRow 가 큰 경우 보정
    final int vStride = (vPlane.bytes.length >= vPlane.bytesPerRow * uvH)
        ? vPlane.bytesPerRow
        : uvW * vPs;
    final int uStride = (uPlane.bytes.length >= uPlane.bytesPerRow * uvH)
        ? uPlane.bytesPerRow
        : uvW * uPs;

    for (int row = 0; row < uvH; row++) {
      for (int col = 0; col < uvW; col++) {
        nv21[pos++] = vPlane.bytes[row * vStride + col * vPs];
        nv21[pos++] = uPlane.bytes[row * uStride + col * uPs];
      }
    }

    return nv21;
  }

  InputImageRotation _sensorToRotation(int deg) {
    switch (deg) {
      case 90:  return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default:  return InputImageRotation.rotation0deg;
    }
  }

  // ── 파생 지표 계산 ────────────────────────────────────────────────────────
  FaceFeatures _extractFeatures(List<LandmarkPoint> lm) {
    if (lm.length < LandmarkPairs.requiredSize) {
      return const FaceFeatures(
        eyeSpan: 0, faceHeight: 0, noseRatio: 0,
        mouthWidth: 0, symmetry: 0, foreheadHeight: 0, eyebrowDistance: 0,
      );
    }

    final eyeSpan = (lm[LandmarkPairs.rightEyeInner].x -
                     lm[LandmarkPairs.leftEyeInner].x).abs();
    final faceHeight = (lm[LandmarkPairs.chin].y -
                        lm[LandmarkPairs.foreheadTop].y).abs();
    final noseRatio = faceHeight > 1e-6
        ? (lm[LandmarkPairs.noseTip].y - lm[LandmarkPairs.foreheadTop].y) /
          faceHeight
        : double.nan;
    final mouthWidth = (lm[LandmarkPairs.mouthRight].x -
                        lm[LandmarkPairs.mouthLeft].x).abs();
    final symmetry = ((lm[LandmarkPairs.noseTip].x -
                       lm[LandmarkPairs.leftEyeInner].x) -
                      (lm[LandmarkPairs.rightEyeInner].x -
                       lm[LandmarkPairs.noseTip].x)).abs();
    final foreheadH = (lm[LandmarkPairs.noseBridge].y -
                       lm[LandmarkPairs.foreheadTop].y).abs();
    final eyebrowDist = (lm[LandmarkPairs.leftBrowInner].y -
                         lm[LandmarkPairs.leftEyeInner].y).abs();

    return FaceFeatures(
      eyeSpan: eyeSpan,
      faceHeight: faceHeight,
      noseRatio: noseRatio,
      mouthWidth: mouthWidth,
      symmetry: symmetry,
      foreheadHeight: foreheadH,
      eyebrowDistance: eyebrowDist,
    );
  }

  void dispose() {
    _detector?.close();
    _detector = null;
  }
}

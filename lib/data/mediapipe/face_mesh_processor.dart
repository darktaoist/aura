import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import '../../domain/entities/landmark_result.dart';
import '../../domain/physiognomy/landmark_index.dart';

/// FaceMeshProcessor FFI 래퍼
class FaceMeshService {
  FaceMeshService._();

  FaceMeshProcessor? _processor;
  bool get isReady => _processor != null;

  static Future<FaceMeshService> create() async {
    final svc = FaceMeshService._();
    svc._processor = await FaceMeshProcessor.create(
      delegate: FaceMeshDelegate.xnnpack,
      enableRoiTracking: true,
      minDetectionConfidence: 0.5,
    );
    return svc;
  }

  /// CameraImage(YUV420) → FaceLandmarkResult?
  FaceLandmarkResult? process(CameraImage image, CameraDescription camera) {
    final processor = _processor;
    if (processor == null) return null;

    try {
      final nv21 = _toNv21(image);
      final rotation = camera.sensorOrientation;
      final isFront = camera.lensDirection == CameraLensDirection.front;

      final result = processor.processNv21(
        nv21,
        rotationDegrees: rotation,
        mirrorHorizontal: isFront,
      );

      if (result.landmarks.isEmpty) return null;

      final points = result.landmarks
          .map((l) => LandmarkPoint(x: l.x, y: l.y, z: l.z))
          .toList();

      return FaceLandmarkResult(
        landmarks: points,
        score: result.score,
        features: _extractFeatures(points),
        frameWidth: image.width,
        frameHeight: image.height,
      );
    } catch (e) {
      debugPrint('[FaceMeshService] process error: $e');
      return null;
    }
  }

  // ── NV21 변환 ─────────────────────────────────────────────────────────────
  //
  // Android YUV_420_888 U/V 평면은 rowStride != width/2 인 기기가 있음
  // (Samsung, Pixel 6a 등). 패딩을 무시하면 행 정렬 오류 → 랜드마크 위치 왜곡.
  // row-by-row 재구성으로 rowStride / pixelStride 를 올바르게 반영한다.
  FaceMeshNv21Image _toNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final bool isInterleaved = (vPlane.bytesPerPixel ?? 1) == 2;
    final Uint8List vuBytes;

    if (isInterleaved) {
      // 이미 VU 인터리브 형태 — 직접 사용
      vuBytes = vPlane.bytes;
    } else {
      // Planar 포맷: rowStride / pixelStride 준수하며 VU 재구성
      final w = image.width;
      final h = image.height;
      final uvW = w ~/ 2;
      final uvH = h ~/ 2;

      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;
      final uvRowStride  = uPlane.bytesPerRow;
      final uvPixelStride = uPlane.bytesPerPixel ?? 1;

      // 출력: tight-packed VU (width 기준)
      vuBytes = Uint8List(uvW * uvH * 2);
      for (int y = 0; y < uvH; y++) {
        for (int x = 0; x < uvW; x++) {
          final srcIdx = y * uvRowStride + x * uvPixelStride;
          final dstIdx = (y * uvW + x) * 2;
          vuBytes[dstIdx]     = vBytes[srcIdx];
          vuBytes[dstIdx + 1] = uBytes[srcIdx];
        }
      }
    }

    return FaceMeshNv21Image(
      yPlane: yPlane.bytes,
      vuPlane: vuBytes,
      width: image.width,
      height: image.height,
      yBytesPerRow: yPlane.bytesPerRow,
      // 인터리브: 원본 rowStride / Planar: tight-packed이므로 width
      vuBytesPerRow: isInterleaved ? vPlane.bytesPerRow : image.width,
    );
  }

  // ── 파생 지표 계산 ────────────────────────────────────────────────────────
  FaceFeatures _extractFeatures(List<LandmarkPoint> lm) {
    // MediaPipe 468 랜드마크 전체가 필요
    if (lm.length < LandmarkPairs.requiredSize) {
      return const FaceFeatures(
        eyeSpan: 0, faceHeight: 0, noseRatio: 0,
        mouthWidth: 0, symmetry: 0, foreheadHeight: 0, eyebrowDistance: 0,
      );
    }

    final eyeSpan    = (lm[LandmarkPairs.rightEyeInner].x -
                        lm[LandmarkPairs.leftEyeInner].x).abs();
    final faceHeight = (lm[LandmarkPairs.chin].y -
                        lm[LandmarkPairs.foreheadTop].y).abs();

    // faceHeight == 0이면 null을 반환할 수 없는 double 타입이므로 NaN 사용
    // 하위에서 isNaN 체크로 분석 스킵
    final noseRatio = faceHeight > 1e-6
        ? (lm[LandmarkPairs.noseTip].y - lm[LandmarkPairs.foreheadTop].y) /
          faceHeight
        : double.nan;

    final mouthWidth  = (lm[LandmarkPairs.mouthRight].x -
                         lm[LandmarkPairs.mouthLeft].x).abs();
    final symmetry    = ((lm[LandmarkPairs.noseTip].x -
                          lm[LandmarkPairs.leftEyeInner].x) -
                         (lm[LandmarkPairs.rightEyeInner].x -
                          lm[LandmarkPairs.noseTip].x)).abs();
    final foreheadH   = (lm[LandmarkPairs.noseBridge].y -
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
    _processor?.close();
    _processor = null;
  }
}

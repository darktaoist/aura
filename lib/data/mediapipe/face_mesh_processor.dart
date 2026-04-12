import 'dart:typed_data';

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
  FaceMeshNv21Image _toNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final bool isInterleaved = (vPlane.bytesPerPixel ?? 1) == 2;
    final Uint8List vuBytes;

    if (isInterleaved) {
      vuBytes = vPlane.bytes;
    } else {
      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;
      final len = uBytes.length;
      vuBytes = Uint8List(len * 2);
      for (int i = 0; i < len; i++) {
        vuBytes[i * 2]     = vBytes[i];
        vuBytes[i * 2 + 1] = uBytes[i];
      }
    }

    return FaceMeshNv21Image(
      yPlane: yPlane.bytes,
      vuPlane: vuBytes,
      width: image.width,
      height: image.height,
      yBytesPerRow: yPlane.bytesPerRow,
      vuBytesPerRow: isInterleaved ? vPlane.bytesPerRow : image.width,
    );
  }

  // ── 파생 지표 계산 ────────────────────────────────────────────────────────
  FaceFeatures _extractFeatures(List<LandmarkPoint> lm) {
    if (lm.length <= LandmarkPairs.chin) {
      return const FaceFeatures(
        eyeSpan: 0, faceHeight: 0, noseRatio: 0,
        mouthWidth: 0, symmetry: 0, foreheadHeight: 0, eyebrowDistance: 0,
      );
    }

    final eyeSpan     = (lm[LandmarkPairs.rightEyeInner].x -
                         lm[LandmarkPairs.leftEyeInner].x).abs();
    final faceHeight  = (lm[LandmarkPairs.chin].y -
                         lm[LandmarkPairs.foreheadTop].y).abs();
    final noseRatio   = faceHeight > 0
        ? (lm[LandmarkPairs.noseTip].y - lm[LandmarkPairs.foreheadTop].y) /
          faceHeight
        : 0.5;
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

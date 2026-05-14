import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:hand_landmarker/hand_landmarker_bindings.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:jni/jni.dart';

import '../../domain/entities/landmark_result.dart';
import '../../domain/entities/palm_result.dart';

/// MediaPipe HandLandmarker 서비스 (hand_landmarker 패키지)
///
/// detect() 는 동기 호출이지만 Future 래핑으로 face_mesh_service 와 동일 패턴 유지.
/// 후면 카메라 기준: sensorOrientation 일반적으로 90° 또는 270°.
class HandLandmarkService {
  HandLandmarkService._();

  HandLandmarkerPlugin? _plugin;
  bool _pluginInitialized = false;
  bool get isReady => _pluginInitialized;

  // 갤러리 파일 전용 — CPU delegate, 첫 호출 시 lazy init
  MyHandLandmarker? _fileDetector;

  bool _coordsLogged = false;

  static Future<HandLandmarkService> create() async {
    // create()는 즉시 반환 — GPU 플러그인은 warmUp() 또는 첫 process() 호출 시 lazy init.
    // HandLandmarkerPlugin.create()는 동기 플랫폼 채널 호출이라 여기서 실행하면
    // Dart 메인 이솔레이트를 블록해 화면 전환 자체가 멈춰 보임.
    return HandLandmarkService._();
  }

  /// 카메라 프리뷰가 렌더된 직후 호출해 플러그인을 명시적으로 초기화한다.
  /// 이미지 스트림 콜백 내에서 lazy init이 일어나는 것을 방지한다.
  void warmUp() {
    if (!_pluginInitialized) _getPlugin();
  }

  HandLandmarkerPlugin _getPlugin() {
    if (!_pluginInitialized) {
      final t0 = DateTime.now();
      _plugin = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.6,
        delegate: HandLandmarkerDelegate.gpu,
      );
      _pluginInitialized = true;
      debugPrint('[HandLandmarkService] plugin init: '
          '${DateTime.now().difference(t0).inMilliseconds}ms');
    }
    return _plugin!;
  }

  /// CameraImage → PalmLandmarkResult?  (async 래퍼)
  /// isLeftHand는 display 좌표 기반으로 자동 감지된다 (thumb tip x > wrist x → 왼손).
  Future<PalmLandmarkResult?> process(
    CameraImage image,
    CameraDescription camera,
  ) async {
    final plugin = _getPlugin();

    try {
      final List<Hand> hands = plugin.detect(
        image,
        camera.sensorOrientation,
      );

      if (hands.isEmpty) return null;

      final hand = hands.first;
      final rawLandmarks = hand.landmarks;

      if (rawLandmarks.length < 21) return null;

      final isFront = camera.lensDirection == CameraLensDirection.front;
      final isTransposed =
          camera.sensorOrientation == 90 || camera.sensorOrientation == 270;
      final int dispWidth = isTransposed ? image.height : image.width;
      final int dispHeight = isTransposed ? image.width : image.height;

      // hand_landmarker 는 MLKit 와 달리 raw sensor [0,1] 정규화 좌표를 반환한다.
      // (MLKit 는 내부 회전 후 portrait 픽셀 좌표 반환, hand_landmarker 는 raw 공간)
      // 따라서 sensorOrientation 에 따라 rotation 변환을 수동 적용해야 한다.
      //   90° CW : (x,y) → (1-y, x)
      //   270° CW: (x,y) → (y, 1-x)   then front mirror → (1-y, 1-x)
      final points = rawLandmarks.map((l) {
        double nx, ny;
        switch (camera.sensorOrientation) {
          case 90:
            nx = 1.0 - l.y;
            ny = l.x;
          case 270:
            nx = l.y;
            ny = 1.0 - l.x;
          case 180:
            nx = 1.0 - l.x;
            ny = 1.0 - l.y;
          default:
            nx = l.x;
            ny = l.y;
        }
        if (isFront) nx = 1.0 - nx;
        return LandmarkPoint(x: nx.clamp(0.0, 1.0), y: ny.clamp(0.0, 1.0), z: l.z);
      }).toList();

      if (!_coordsLogged) {
        _coordsLogged = true;
        final p0 = rawLandmarks[0];
        final t0 = points[0];
        debugPrint('[HandLandmarkService] ── 첫 포인트 ──\n'
            '  image: ${image.width}×${image.height} '
            'sensorOri=${camera.sensorOrientation} isFront=$isFront\n'
            '  wrist raw: x=${p0.x.toStringAsFixed(3)} y=${p0.y.toStringAsFixed(3)}\n'
            '  wrist disp: x=${t0.x.toStringAsFixed(3)} y=${t0.y.toStringAsFixed(3)}\n'
            '  dispW=$dispWidth dispH=$dispHeight');
      }

      // display 좌표에서 thumb tip(4)이 wrist(0)보다 오른쪽이면 왼손
      // (전면 카메라 mirror + 회전 변환 후 기준)
      final detectedIsLeft = points[4].x > points[0].x;

      return PalmLandmarkResult(
        landmarks: points,
        score: 1.0,
        features: _extractFeatures(points),
        frameWidth: dispWidth,
        frameHeight: dispHeight,
        isLeftHand: detectedIsLeft,
      );
    } catch (e, st) {
      debugPrint('[HandLandmarkService] process error: $e\n$st');
      return null;
    }
  }

  // ── 정적 이미지(갤러리) 처리 ──────────────────────────────────────────────

  /// 갤러리 사진 파일 경로 → PalmLandmarkResult?
  /// EXIF 보정 후 I420 변환 → JNI detectFromYuv 호출 (CPU delegate).
  /// isLeftHand는 자동 감지된다 (thumb tip x > wrist x 기준).
  Future<PalmLandmarkResult?> processFile(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final raw = img_pkg.decodeImage(bytes);
      if (raw == null) return null;

      final oriented = img_pkg.bakeOrientation(raw);
      final sized = _resizeForDetection(oriented);
      final w = sized.width;
      final h = sized.height;

      final (yPlane, uPlane, vPlane) = _imageToI420(sized);
      final uvW = w ~/ 2;

      _fileDetector ??= MyHandLandmarker(Jni.androidApplicationContext)
        ..initialize(1, 0.6, false); // CPU delegate: GPU 충돌 방지

      final yBuf = JByteBuffer.fromList(yPlane);
      final uBuf = JByteBuffer.fromList(uPlane);
      final vBuf = JByteBuffer.fromList(vPlane);

      final resultJStr = _fileDetector!.detectFromYuv(
        yBuf, uBuf, vBuf,
        w, h,
        w,    // yBytesPerRow
        uvW,  // uBytesPerRow
        1,    // uBytesPerPixel (planar)
        0,    // sensorOrientation: EXIF 이미 보정됨
      );

      yBuf.release(); uBuf.release(); vBuf.release();
      final str = resultJStr.toDartString();
      resultJStr.release();

      if (str.isEmpty || str == '[]') return null;

      final parsed = jsonDecode(str) as List<dynamic>;
      if (parsed.isEmpty) return null;

      final landmarks = (parsed.first as List<dynamic>).map((d) {
        final m = d as Map<String, dynamic>;
        return LandmarkPoint(
          x: (m['x'] as num).toDouble().clamp(0.0, 1.0),
          y: (m['y'] as num).toDouble().clamp(0.0, 1.0),
          z: (m['z'] as num).toDouble(),
        );
      }).toList();

      if (landmarks.length < 21) return null;

      final detectedIsLeft = landmarks[4].x > landmarks[0].x;

      return PalmLandmarkResult(
        landmarks: landmarks,
        score: 1.0,
        features: _extractFeatures(landmarks),
        frameWidth: w,
        frameHeight: h,
        isLeftHand: detectedIsLeft,
      );
    } catch (e, st) {
      debugPrint('[HandLandmarkService] processFile error: $e\n$st');
      return null;
    }
  }

  img_pkg.Image _resizeForDetection(img_pkg.Image image) {
    const maxDim = 1280;
    if (image.width <= maxDim && image.height <= maxDim) return image;
    return image.width > image.height
        ? img_pkg.copyResize(image, width: maxDim)
        : img_pkg.copyResize(image, height: maxDim);
  }

  /// RGB → I420 planar (Y, U, V 분리 배열)
  (Uint8List, Uint8List, Uint8List) _imageToI420(img_pkg.Image image) {
    final w = image.width;
    final h = image.height;
    final uvW = w ~/ 2;
    final uvH = h ~/ 2;

    final y = Uint8List(w * h);
    final u = Uint8List(uvW * uvH);
    final v = Uint8List(uvW * uvH);

    int yPos = 0, uvPos = 0;
    int col = 0, row = 0;

    for (final px in image) {
      final r = px.r.toInt();
      final g = px.g.toInt();
      final b = px.b.toInt();

      y[yPos++] = (((66 * r + 129 * g + 25 * b + 128) >> 8) + 16).clamp(16, 235);

      if (row.isEven && col.isEven) {
        u[uvPos] = (((-38 * r - 74 * g + 112 * b + 128) >> 8) + 128).clamp(16, 240);
        v[uvPos] = (((112 * r - 94 * g - 18 * b + 128) >> 8) + 128).clamp(16, 240);
        uvPos++;
      }

      col++;
      if (col >= w) { col = 0; row++; }
    }

    return (y, u, v);
  }

  // ── 파생 지표 계산 ────────────────────────────────────────────────────────
  // MediaPipe hand landmarks:
  //  0: WRIST
  //  1-4: THUMB (CMC→MCP→IP→TIP)
  //  5-8: INDEX  (MCP→PIP→DIP→TIP)
  //  9-12: MIDDLE, 13-16: RING, 17-20: PINKY
  PalmFeatures _extractFeatures(List<LandmarkPoint> lm) {
    double d(int a, int b) {
      final dx = lm[a].x - lm[b].x;
      final dy = lm[a].y - lm[b].y;
      return math.sqrt(dx * dx + dy * dy);
    }

    final palmWidth = d(5, 17); // index MCP ~ pinky MCP
    final thumbLength = d(1, 4);
    final indexLength = d(5, 8);
    final middleLength = d(9, 12);
    final ringLength = d(13, 16);
    final pinkyLength = d(17, 20);

    // 손가락 끝 x좌표 분산 → 손가락 펼침 정도
    final tipXs = [lm[4].x, lm[8].x, lm[12].x, lm[16].x, lm[20].x];
    final meanX = tipXs.reduce((a, b) => a + b) / tipXs.length;
    final variance = tipXs.fold(0.0, (acc, x) => acc + (x - meanX) * (x - meanX)) / tipXs.length;
    final fingerSpread = math.sqrt(variance);

    return PalmFeatures(
      palmWidth: palmWidth,
      indexLength: indexLength,
      middleLength: middleLength,
      ringLength: ringLength,
      pinkyLength: pinkyLength,
      thumbLength: thumbLength,
      fingerSpread: fingerSpread,
    );
  }

  void dispose() {
    _plugin?.dispose();
    _plugin = null;
    _pluginInitialized = false;
    _fileDetector?.release();
    _fileDetector = null;
  }
}

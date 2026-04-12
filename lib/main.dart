import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'model_download_screen.dart';

// ── 관상 주요 랜드마크 인덱스 (MediaPipe 468점 기준) ──────────────────────
const Map<String, int> kKeyLandmarks = {
  '이마': 10,
  '코끝': 4,
  '코다리': 168,
  '인중': 0,
  '턱': 152,
  '왼눈(내각)': 133,
  '왼눈(외각)': 33,
  '오른눈(내각)': 362,
  '오른눈(외각)': 263,
  '입(왼)': 61,
  '입(오른)': 291,
  '왼볼': 234,
  '오른볼': 454,
  '왼눈썹(내)': 107,
  '왼눈썹(외)': 46,
  '오른눈썹(내)': 336,
  '오른눈썹(외)': 276,
};

// ── System Instruction (관상 전문가 역할) ───────────────────────────────────
const String _kSystemInstruction = '''
당신은 한국 전통 관상학 전문가입니다.
사용자가 제공하는 얼굴 측정 데이터를 바탕으로 간결하고 흥미로운 관상 분석을 제공하세요.
- 반드시 한국어로 답변하세요
- 2~3문장으로 핵심만 간결하게
- 성격, 운세, 특징 중 1~2가지에 집중
- 수치보다 의미를 풀어서 설명
''';

// ───────────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  final cameras = await availableCameras();
  runApp(GwansangApp(cameras: cameras));
}

class GwansangApp extends StatelessWidget {
  const GwansangApp({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '관상 AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: _AppRouter(cameras: cameras),
    );
  }
}

/// 모델 설치 여부에 따라 다운로드 화면 or 메인 화면으로 라우팅
class _AppRouter extends StatefulWidget {
  const _AppRouter({required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool? _modelReady; // null=확인중, false=미설치, true=준비됨

  @override
  void initState() {
    super.initState();
    _checkModel();
  }

  Future<void> _checkModel() async {
    final isInstalled = FlutterGemma.hasActiveModel();
    setState(() => _modelReady = isInstalled);
  }

  @override
  Widget build(BuildContext context) {
    if (_modelReady == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_modelReady == false) {
      return ModelSetupScreen(
        onComplete: () => setState(() => _modelReady = true),
      );
    }
    return FaceMeshScreen(cameras: widget.cameras);
  }
}

// ── 메인 화면 ──────────────────────────────────────────────────────────────
class FaceMeshScreen extends StatefulWidget {
  const FaceMeshScreen({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<FaceMeshScreen> createState() => _FaceMeshScreenState();
}

class _FaceMeshScreenState extends State<FaceMeshScreen> {
  // Camera
  CameraController? _cameraController;
  CameraDescription? _activeCamera;

  // FaceMesh
  FaceMeshProcessor? _faceMesh;
  FaceMeshResult? _result;
  bool _processing = false;
  int _frameCount = 0;

  // Gemma
  InferenceModel? _gemmaModel;
  InferenceChat? _gemmaChat;
  bool _gemmaReady = false;
  bool _gemmaAnalyzing = false;
  String _gwansangText = '';
  String _statusText = '초기화 중...';
  DateTime _lastAnalysis = DateTime.fromMillisecondsSinceEpoch(0);


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ── 초기화 ──────────────────────────────────────────────────────────────
  Future<void> _initialize() async {
    await _initCamera();
    await _initFaceMesh();
    await _loadGemma();
  }

  Future<void> _initCamera() async {
    final camera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );
    _activeCamera = camera;

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await controller.initialize();
      _cameraController = controller;
    } catch (e) {
      _setStatus('카메라 초기화 실패: $e');
    }
  }

  Future<void> _initFaceMesh() async {
    _setStatus('FaceMesh 엔진 로딩 중...');
    try {
      _faceMesh = await FaceMeshProcessor.create(
        delegate: FaceMeshDelegate.xnnpack,
        enableRoiTracking: true,
        minDetectionConfidence: 0.5,
      );
      await _cameraController?.startImageStream(_onCameraImage);
    } catch (e) {
      _setStatus('FaceMesh 초기화 실패: $e');
    }
  }

  Future<void> _loadGemma() async {
    _setStatus('Gemma 모델 로딩 중...');
    try {
      // 이미 다운로드된 활성 모델을 불러옴
      _gemmaModel = await FlutterGemma.getActiveModel(maxTokens: 2048);
      setState(() {
        _gemmaReady = true;
        _statusText = '얼굴을 카메라에 보여주세요';
      });
    } catch (e) {
      setState(() {
        _gemmaReady = false;
        _statusText = 'Gemma 로드 실패: $e';
      });
    }
  }

  // ── 카메라 프레임 처리 ───────────────────────────────────────────────────
  void _onCameraImage(CameraImage image) {
    if (_processing || _faceMesh == null) return;
    // 15fps 제한
    _processing = true;
    try {
      final nv21 = _toNv21(image);
      final rotation = _activeCamera?.sensorOrientation ?? 90;
      final isFront =
          _activeCamera?.lensDirection == CameraLensDirection.front;

      final result = _faceMesh!.processNv21(
        nv21,
        rotationDegrees: rotation,
        mirrorHorizontal: isFront,
      );

      if (result.landmarks.isNotEmpty) {
        _frameCount++;
        if (mounted) setState(() => _result = result);

        // 콘솔 로그 (30프레임마다)
        if (_frameCount % 30 == 1) _logLandmarks(result);

        // Gemma 분석 (5초마다, Gemma 준비됐을 때만)
        final now = DateTime.now();
        if (_gemmaReady &&
            !_gemmaAnalyzing &&
            now.difference(_lastAnalysis).inSeconds >= 5) {
          _lastAnalysis = now;
          _analyzeWithGemma(result);
        }
      } else {
        if (mounted) setState(() => _result = null);
      }
    } catch (e) {
      debugPrint('[FaceMesh] 오류: $e');
    } finally {
      _processing = false;
    }
  }

  // ── NV21 변환 ────────────────────────────────────────────────────────────
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
        vuBytes[i * 2] = vBytes[i];
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

  // ── Gemma 관상 분석 ──────────────────────────────────────────────────────
  Future<void> _analyzeWithGemma(FaceMeshResult result) async {
    if (!_gemmaReady || _gemmaAnalyzing) return;
    setState(() {
      _gemmaAnalyzing = true;
      _gwansangText = '분석 중...';
    });

    try {
      // 새 채팅 세션 (매 분석마다 fresh context)
      final chat = await _gemmaModel!.createChat(
        modelType: ModelType.gemmaIt,
        systemInstruction: _kSystemInstruction,
        temperature: 0.7,
        topK: 40,
      );

      final prompt = _buildPrompt(result);
      debugPrint('[Gemma] 프롬프트:\n$prompt');

      await chat.addQueryChunk(Message(text: prompt, isUser: true));

      final buffer = StringBuffer();
      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          buffer.write(response.token);
          if (mounted) {
            setState(() => _gwansangText = buffer.toString());
          }
        }
      }

      debugPrint('[Gemma] 분석 결과: ${buffer.toString()}');
    } catch (e) {
      debugPrint('[Gemma] 오류: $e');
      if (mounted) setState(() => _gwansangText = '분석 오류: $e');
    } finally {
      if (mounted) setState(() => _gemmaAnalyzing = false);
    }
  }

  // ── Gemma 프롬프트 생성 ─────────────────────────────────────────────────
  String _buildPrompt(FaceMeshResult result) {
    final lm = result.landmarks;
    if (lm.length <= 454) return '얼굴 데이터가 불충분합니다.';

    final eyeSpan = (lm[362].x - lm[133].x).abs();
    final faceH = (lm[152].y - lm[10].y).abs();
    final noseRatio = faceH > 0 ? (lm[4].y - lm[10].y) / faceH : 0.5;
    final mouthW = (lm[291].x - lm[61].x).abs();
    final symmetry = ((lm[4].x - lm[133].x) - (lm[362].x - lm[4].x)).abs();
    final foreheadH = (lm[168].y - lm[10].y).abs();
    final eyebrowDist = (lm[107].y - lm[133].y).abs();

    // 정규화 기술어 변환
    String eyeDesc = eyeSpan > 0.18
        ? '넓음'
        : eyeSpan > 0.14
        ? '보통'
        : '좁음';
    String noseDesc = noseRatio > 0.6
        ? '길고 뚜렷함'
        : noseRatio > 0.5
        ? '균형잡힘'
        : '짧고 올라감';
    String mouthDesc = mouthW > 0.25
        ? '크고 넓음'
        : mouthW > 0.18
        ? '보통'
        : '작고 단정함';
    String symDesc = symmetry < 0.05
        ? '매우 대칭'
        : symmetry < 0.12
        ? '보통 대칭'
        : '약간 비대칭';
    String foreheadDesc = foreheadH > 0.15
        ? '넓고 높음'
        : foreheadH > 0.10
        ? '보통'
        : '좁고 낮음';
    String eyebrowDesc = eyebrowDist < 0.03
        ? '눈과 가까움'
        : eyebrowDist < 0.06
        ? '보통'
        : '눈과 멀음';

    return '''
다음 얼굴 특징을 분석해 주세요:
- 이마: $foreheadDesc
- 눈 간격: $eyeDesc
- 코 형태: $noseDesc
- 입 크기: $mouthDesc
- 눈썹: $eyebrowDesc
- 좌우 대칭: $symDesc

이 얼굴의 관상 특징을 2~3문장으로 분석해 주세요.
''';
  }

  // ── 콘솔 로그 ───────────────────────────────────────────────────────────
  void _logLandmarks(FaceMeshResult result) {
    final lm = result.landmarks;
    final buf = StringBuffer();
    buf.writeln('\n╔══════════════════════════════════════════');
    buf.writeln(
        '║ Face Mesh │ score: ${result.score.toStringAsFixed(3)} │ ${lm.length}점');
    buf.writeln('╠══════════════════════════════════════════');
    for (final e in kKeyLandmarks.entries) {
      final idx = e.value;
      if (idx < lm.length) {
        final l = lm[idx];
        buf.writeln(
          '║ ${e.key.padRight(10)} x=${l.x.toStringAsFixed(3)}  y=${l.y.toStringAsFixed(3)}',
        );
      }
    }
    if (lm.length > 454) {
      final eyeSpan = (lm[362].x - lm[133].x).abs();
      final faceH = (lm[152].y - lm[10].y).abs();
      buf.writeln('╠══════════════════════════════════════════');
      buf.writeln(
          '║ 눈간격:${eyeSpan.toStringAsFixed(3)} 얼굴높이:${faceH.toStringAsFixed(3)}');
    }
    buf.writeln('╚══════════════════════════════════════════');
    debugPrint(buf.toString());
  }

  void _setStatus(String msg) {
    if (mounted) setState(() => _statusText = msg);
  }


  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceMesh?.close();
    _gemmaModel?.close();
    super.dispose();
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final isReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('관상 AI'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: const [],
      ),
      body: isReady
          ? Column(
              children: [
                // 카메라 + 랜드마크 오버레이
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(controller),
                      if (_result != null)
                        CustomPaint(painter: LandmarkPainter(result: _result!)),
                      // 상태 표시 (얼굴 미감지 시)
                      if (_result == null)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusText,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 관상 분석 결과 패널
                _GwansangPanel(
                  text: _gwansangText,
                  isAnalyzing: _gemmaAnalyzing,
                  gemmaReady: _gemmaReady,
                  faceMeshActive: _result != null,
                  onSetupTap: () {},
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusText,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
    );
  }
}

// ── 관상 결과 패널 ─────────────────────────────────────────────────────────
class _GwansangPanel extends StatelessWidget {
  const _GwansangPanel({
    required this.text,
    required this.isAnalyzing,
    required this.gemmaReady,
    required this.faceMeshActive,
    required this.onSetupTap,
  });

  final String text;
  final bool isAnalyzing;
  final bool gemmaReady;
  final bool faceMeshActive;
  final VoidCallback onSetupTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.indigo.shade700, width: 1)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 14,
                  color: gemmaReady ? Colors.indigoAccent : Colors.grey),
              const SizedBox(width: 6),
              Text(
                gemmaReady ? 'Gemma 관상 분석' : 'Gemma 미연결',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: gemmaReady ? Colors.indigoAccent : Colors.grey,
                ),
              ),
              if (isAnalyzing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ],
              const Spacer(),
              if (!gemmaReady)
                TextButton(
                  onPressed: onSetupTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('모델 설정', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                text.isNotEmpty
                    ? text
                    : gemmaReady
                        ? faceMeshActive
                            ? '얼굴 감지됨 - 5초마다 자동 분석'
                            : '얼굴을 카메라에 보여주세요'
                        : '오른쪽 상단 폴더 아이콘을 눌러 Gemma 모델 경로를 설정하세요.\n\n'
                            '예) adb push gemma4.litertlm /data/local/tmp/gemma4.litertlm',
                style: TextStyle(
                  color: text.isNotEmpty ? Colors.white : Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 랜드마크 오버레이 Painter ─────────────────────────────────────────────
class LandmarkPainter extends CustomPainter {
  const LandmarkPainter({required this.result});
  final FaceMeshResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final meshPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (final lm in result.landmarks) {
      final x = lm.x.clamp(0.0, 1.0) * size.width;
      final y = lm.y.clamp(0.0, 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 1.6, meshPaint);
    }

    final keyPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    final textStyle = const TextStyle(
      color: Colors.yellowAccent,
      fontSize: 9,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
    );

    for (final entry in kKeyLandmarks.entries) {
      final idx = entry.value;
      if (idx >= result.landmarks.length) continue;
      final lm = result.landmarks[idx];
      final x = lm.x.clamp(0.0, 1.0) * size.width;
      final y = lm.y.clamp(0.0, 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 4.5, keyPaint);
      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 5, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant LandmarkPainter old) =>
      !identical(old.result, result);
}

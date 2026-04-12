import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mediapipe/face_mesh_processor.dart';
import '../../../domain/entities/landmark_result.dart';
import 'widgets/landmark_overlay_painter.dart';
import 'widgets/stability_indicator.dart';

class FaceCameraPage extends ConsumerStatefulWidget {
  const FaceCameraPage({super.key});

  @override
  ConsumerState<FaceCameraPage> createState() => _FaceCameraPageState();
}

class _FaceCameraPageState extends ConsumerState<FaceCameraPage> {
  CameraController? _camera;
  FaceMeshService? _faceMesh;
  FaceLandmarkResult? _lastResult;

  bool _processing = false;
  int _stableFrames = 0;
  int _frameCount = 0;
  DateTime _lastLogTime = DateTime.now();

  bool get _isStable => _stableFrames >= AppConst.stabilityFrames;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final ctrl = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await ctrl.initialize();

    _faceMesh = await FaceMeshService.create();
    await ctrl.startImageStream(_onFrame);

    if (mounted) setState(() => _camera = ctrl);
  }

  void _onFrame(CameraImage image) {
    if (_processing || _faceMesh == null || _camera == null) return;
    _processing = true;

    try {
      final result = _faceMesh!.process(image, _camera!.description);
      if (result != null && result.score >= AppConst.stabilityScore) {
        _stableFrames = (_stableFrames + 1)
            .clamp(0, AppConst.stabilityFrames + 1);
      } else {
        _stableFrames = 0;
      }

      _frameCount++;
      // 콘솔 로그 (30프레임마다)
      if (_frameCount % AppConst.logEveryNFrames == 1) {
        final now = DateTime.now();
        if (now.difference(_lastLogTime).inMilliseconds > 500) {
          _lastLogTime = now;
          debugPrint('[FaceCamera] frames=$_frameCount stable=$_stableFrames '
              'score=${result?.score.toStringAsFixed(3)}');
        }
      }

      if (mounted) setState(() => _lastResult = result);
    } finally {
      _processing = false;
    }
  }

  @override
  void dispose() {
    _camera?.stopImageStream();
    _camera?.dispose();
    _faceMesh?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _camera;
    final isReady = ctrl != null && ctrl.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('관상 보기'),
      ),
      body: isReady
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(ctrl),
                // 랜드마크 오버레이
                if (_lastResult != null)
                  CustomPaint(
                    painter: LandmarkOverlayPainter(result: _lastResult!),
                  ),
                // 상태 표시 (상단)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: StabilityIndicator(
                      progress: _stableFrames / AppConst.stabilityFrames,
                      isStable: _isStable,
                    ),
                  ),
                ),
                // 결과 보기 버튼 (하단, 안정 후 활성)
                Positioned(
                  bottom: 40,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: AnimatedOpacity(
                    opacity: _isStable ? 1.0 : 0.3,
                    duration: AppDuration.overlayFade,
                    child: FilledButton.icon(
                      onPressed: _isStable && _lastResult != null
                          ? () {
                              context.push('/face/result',
                                  extra: _lastResult!);
                            }
                          : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('관상 결과 보기'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        textStyle: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}

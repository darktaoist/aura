import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // ValueNotifier로 랜드마크 오버레이 분리 (프레임마다 전체 rebuild 방지)
  final ValueNotifier<FaceLandmarkResult?> _landmarkNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> _stableFramesNotifier = ValueNotifier(0);

  bool _processing = false;
  bool _disposed = false;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastLogTime = DateTime.now();
  int _frameCount = 0;

  // 권한 상태
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 카메라 권한 확인
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }

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

      if (_disposed) {
        await ctrl.dispose();
        return;
      }

      _faceMesh = await FaceMeshService.create();
      await ctrl.startImageStream(_onFrame);

      if (mounted) setState(() => _camera = ctrl);
    } catch (e) {
      debugPrint('[FaceCamera] init error: $e');
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  void _onFrame(CameraImage image) {
    if (_disposed || _processing || _faceMesh == null || _camera == null) return;

    // 15fps throttle
    final now = DateTime.now();
    if (now.difference(_lastProcessedAt).inMilliseconds <
        AppConst.frameThrottleMs) {
      return;
    }
    _lastProcessedAt = now;
    _processing = true;

    try {
      final result = _faceMesh!.process(image, _camera!.description);

      if (result != null && result.score >= AppConst.stabilityScore) {
        // 안정도 증가 (상한 clamp)
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value + 1).clamp(0, AppConst.stabilityFrames + 1);
      } else {
        // 점진 감소 (5 penalty) — 한 프레임 깜빡임에 즉시 0 리셋하지 않음
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value - 5).clamp(0, AppConst.stabilityFrames + 1);
      }

      // 콘솔 로그 (500ms 게이트)
      _frameCount++;
      if (now.difference(_lastLogTime).inMilliseconds > 500) {
        _lastLogTime = now;
        debugPrint('[FaceCamera] frames=$_frameCount '
            'stable=${_stableFramesNotifier.value} '
            'score=${result?.score.toStringAsFixed(3)}');
      }

      _landmarkNotifier.value = result;
    } finally {
      _processing = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    // 프레임 스트림 + 카메라 + 메시 비동기 정리
    _camera?.stopImageStream().then((_) {
      _camera?.dispose();
    });
    _faceMesh?.dispose();
    _landmarkNotifier.dispose();
    _stableFramesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _buildPermissionDenied(context);
    }

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
                // 랜드마크 오버레이 — RepaintBoundary로 카메라 프리뷰 재빌드 방지
                RepaintBoundary(
                  child: ValueListenableBuilder<FaceLandmarkResult?>(
                    valueListenable: _landmarkNotifier,
                    builder: (_, result, __) {
                      if (result == null) return const SizedBox.shrink();
                      return CustomPaint(
                        painter: LandmarkOverlayPainter(result: result),
                      );
                    },
                  ),
                ),
                // 안정도 표시 (상단)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _stableFramesNotifier,
                      builder: (_, stableFrames, __) {
                        final isStable = stableFrames >= AppConst.stabilityFrames;
                        return StabilityIndicator(
                          progress: stableFrames / AppConst.stabilityFrames,
                          isStable: isStable,
                        );
                      },
                    ),
                  ),
                ),
                // 결과 보기 버튼 (하단)
                Positioned(
                  bottom: 40,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _stableFramesNotifier,
                    builder: (_, stableFrames, __) {
                      final isStable = stableFrames >= AppConst.stabilityFrames;
                      final result = _landmarkNotifier.value;
                      return AnimatedOpacity(
                        opacity: isStable ? 1.0 : 0.3,
                        duration: AppDuration.overlayFade,
                        child: FilledButton.icon(
                          onPressed: isStable && result != null
                              ? () => context.push('/face/result', extra: result)
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
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Widget _buildPermissionDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('관상 보기'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white54, size: 64),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '카메라 권한이 필요합니다',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '얼굴 분석을 위해 카메라 접근 권한을 허용해 주세요',
                style: TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  if (mounted) {
                    setState(() => _permissionDenied = false);
                    _init();
                  }
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('설정에서 권한 허용'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

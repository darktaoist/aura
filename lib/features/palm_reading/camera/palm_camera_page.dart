import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mlkit/hand_landmark_service.dart';
import '../../../domain/entities/palm_result.dart';
import 'widgets/hand_overlay_painter.dart';
import 'widgets/hand_stability_indicator.dart';

class PalmCameraPage extends ConsumerStatefulWidget {
  const PalmCameraPage({super.key});

  @override
  ConsumerState<PalmCameraPage> createState() => _PalmCameraPageState();
}

class _PalmCameraPageState extends ConsumerState<PalmCameraPage> {
  CameraController? _camera;
  HandLandmarkService? _handLandmark;

  final ValueNotifier<PalmLandmarkResult?> _landmarkNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> _stableFramesNotifier = ValueNotifier(0);

  bool _isLeftHand = true;
  bool _processing = false;
  bool _disposed = false;
  bool _navigating = false;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastLogTime = DateTime.now();
  int _frameCount = 0;

  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
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

      // 손금: 전면 카메라 사용 (손바닥을 자신 쪽으로 향하게 촬영)
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

      _handLandmark = await HandLandmarkService.create();
      await ctrl.startImageStream(_onFrame);

      if (mounted) setState(() => _camera = ctrl);
    } catch (e) {
      debugPrint('[PalmCamera] init error: $e');
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  void _onFrame(CameraImage image) {
    if (_disposed || _navigating || _processing || _handLandmark == null || _camera == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessedAt).inMilliseconds <
        AppConst.frameThrottleMs) {
      return;
    }
    _lastProcessedAt = now;
    _processing = true;

    _processFrameAsync(image, now);
  }

  Future<void> _processFrameAsync(CameraImage image, DateTime frameTime) async {
    try {
      final result = await _handLandmark!.process(
        image,
        _camera!.description,
        _isLeftHand,
      );

      if (_disposed) return;

      final bool detected = result != null;

      if (detected) {
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value + 1).clamp(0, AppConst.stabilityFrames + 1);
      } else {
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value - 5).clamp(0, AppConst.stabilityFrames + 1);
      }

      _frameCount++;
      if (frameTime.difference(_lastLogTime).inMilliseconds > 500) {
        _lastLogTime = frameTime;
        debugPrint('[PalmCamera] frames=$_frameCount '
            'stable=${_stableFramesNotifier.value} '
            'detected=$detected');
      }

      _landmarkNotifier.value = result;
    } finally {
      _processing = false;
    }
  }

  Future<void> _goToResult(PalmLandmarkResult result) async {
    _navigating = true;
    try { await _camera?.stopImageStream(); } catch (_) {}

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    await context.push('/palm/result', extra: result);

    if (!mounted || _disposed) return;
    _navigating = false;
    try { await _camera?.startImageStream(_onFrame); } catch (_) {}
  }

  void _onHandToggle(bool isLeft) {
    if (_isLeftHand == isLeft) return;
    setState(() => _isLeftHand = isLeft);
    // 토글 시 안정도 리셋
    _stableFramesNotifier.value = 0;
    _landmarkNotifier.value = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _camera?.stopImageStream().then((_) {
      _camera?.dispose();
    });
    _handLandmark?.dispose();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '손금 보기',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ToggleButtons(
              isSelected: [_isLeftHand, !_isLeftHand],
              onPressed: (i) => _onHandToggle(i == 0),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: Colors.white54,
              selectedColor: Colors.white,
              fillColor: Colors.white24,
              borderColor: Colors.white30,
              selectedBorderColor: Colors.white60,
              constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
              children: const [
                Text('왼손', style: TextStyle(fontSize: 12)),
                Text('오른손', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: isReady
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(ctrl),
                // 손 랜드마크 오버레이
                RepaintBoundary(
                  child: ValueListenableBuilder<PalmLandmarkResult?>(
                    valueListenable: _landmarkNotifier,
                    builder: (_, result, __) {
                      if (result == null) return const SizedBox.shrink();
                      return CustomPaint(
                        painter: HandOverlayPainter(result: result),
                      );
                    },
                  ),
                ),
                // 손 인식 가이드 오버레이
                Positioned.fill(
                  child: ValueListenableBuilder<PalmLandmarkResult?>(
                    valueListenable: _landmarkNotifier,
                    builder: (_, result, __) {
                      if (result != null) return const SizedBox.shrink();
                      return Center(
                        child: Container(
                          width: 240,
                          height: 320,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white30,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.back_hand_outlined,
                                  color: Colors.white30, size: 48),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                '손바닥을 화면 쪽으로\n펼쳐서 보여주세요',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
                        return HandStabilityIndicator(
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
                              ? () => _goToResult(result)
                              : null,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('손금 결과 보기'),
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
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '손금 보기',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
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
                '손금 분석을 위해 카메라 접근 권한을 허용해 주세요',
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

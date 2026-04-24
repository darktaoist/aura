import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mlkit/face_mesh_service.dart';
import '../../../domain/entities/landmark_result.dart';
import '../../../domain/physiognomy/landmark_index.dart';
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

  final ValueNotifier<FaceLandmarkResult?> _landmarkNotifier = ValueNotifier(null);
  final ValueNotifier<int> _stableFramesNotifier = ValueNotifier(0);

  bool _processing = false;
  bool _disposed = false;
  bool _navigating = false;
  FaceLandmarkResult? _lastDetectedResult;
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

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        front, ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // ML 모델 로드를 카메라 초기화와 병렬로 시작
      final modelFuture = FaceMeshService.create();

      await ctrl.initialize();
      if (_disposed) { await ctrl.dispose(); return; }

      // 카메라 준비 즉시 프리뷰 표시 (ML 모델 대기 불필요)
      if (mounted) setState(() => _camera = ctrl);

      // ML 모델 완료 대기 (카메라 화면 보이는 동안 진행)
      _faceMesh = await modelFuture;
      if (_disposed) return;

      await ctrl.startImageStream(_onFrame);
    } catch (e) {
      debugPrint('[FaceCamera] init error: $e');
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  void _onFrame(CameraImage image) {
    if (_disposed || _navigating || _processing || _faceMesh == null || _camera == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessedAt).inMilliseconds < AppConst.frameThrottleMs) return;
    _lastProcessedAt = now;
    _processing = true;
    _processFrameAsync(image, now);
  }

  Future<void> _processFrameAsync(CameraImage image, DateTime frameTime) async {
    try {
      final result = await _faceMesh!.process(image, _camera!.description);
      if (_disposed) return;

      final bool detected = result != null;
      if (detected) {
        _lastDetectedResult = result;
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value + 1).clamp(0, AppConst.stabilityFrames + 1);
      } else if (_stableFramesNotifier.value < AppConst.stabilityFrames) {
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value - 5).clamp(0, AppConst.stabilityFrames + 1);
      }

      _frameCount++;
      if (frameTime.difference(_lastLogTime).inMilliseconds > 500) {
        _lastLogTime = frameTime;
        debugPrint('[FaceCamera] frames=$_frameCount stable=${_stableFramesNotifier.value} detected=$detected');
      }
      _landmarkNotifier.value = result;
    } finally {
      _processing = false;
    }
  }

  Future<void> _goToResult(dynamic result) async {
    _navigating = true;
    try { await _camera?.stopImageStream(); } catch (_) {}
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    await context.push('/face/result', extra: result);
    if (!mounted || _disposed) return;
    _navigating = false;
    try { await _camera?.startImageStream(_onFrame); } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _camera?.stopImageStream().then((_) => _camera?.dispose());
    _faceMesh?.dispose();
    _landmarkNotifier.dispose();
    _stableFramesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_permissionDenied) return _buildPermissionDenied(context, l10n);

    final ctrl = _camera;
    final isReady = ctrl != null && ctrl.value.isInitialized;
    final locale = Localizations.localeOf(context).languageCode;
    final labels = keyLandmarkLabels(locale);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.faceReading,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: isReady
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(ctrl),
                RepaintBoundary(
                  child: ValueListenableBuilder<FaceLandmarkResult?>(
                    valueListenable: _landmarkNotifier,
                    builder: (_, result, __) {
                      if (result == null) return const SizedBox.shrink();
                      return CustomPaint(painter: LandmarkOverlayPainter(result: result, labels: labels));
                    },
                  ),
                ),
                Positioned(
                  top: 12, left: 0, right: 0,
                  child: Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _stableFramesNotifier,
                      builder: (_, stableFrames, __) => StabilityIndicator(
                        progress: stableFrames / AppConst.stabilityFrames,
                        isStable: stableFrames >= AppConst.stabilityFrames,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _stableFramesNotifier,
                    builder: (_, stableFrames, __) {
                      final isStable = stableFrames >= AppConst.stabilityFrames;
                      final captured = _lastDetectedResult;
                      return AnimatedOpacity(
                        opacity: isStable ? 1.0 : 0.3,
                        duration: AppDuration.overlayFade,
                        child: FilledButton.icon(
                          onPressed: isStable && captured != null
                              ? () => _goToResult(captured)
                              : null,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(l10n.viewResults),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildPermissionDenied(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.faceReading,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
              const Icon(Icons.no_photography_outlined, color: Colors.white54, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.cameraPermissionRequired,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.facePermissionDesc,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  if (mounted) { setState(() => _permissionDenied = false); _init(); }
                },
                icon: const Icon(Icons.settings_outlined),
                label: Text(l10n.openSettings),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack, style: const TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

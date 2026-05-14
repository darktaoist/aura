import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/camera_stability_card.dart';
import '../../../data/mlkit/hand_landmark_service.dart';
import '../../../domain/entities/palm_result.dart';
import '../../../domain/physiognomy/hand_connections.dart';
import 'widgets/hand_overlay_painter.dart';

class PalmCameraPage extends ConsumerStatefulWidget {
  const PalmCameraPage({super.key});

  @override
  ConsumerState<PalmCameraPage> createState() => _PalmCameraPageState();
}

class _PalmCameraPageState extends ConsumerState<PalmCameraPage> {
  CameraController? _camera;
  HandLandmarkService? _handLandmark;

  final ValueNotifier<PalmLandmarkResult?> _landmarkNotifier = ValueNotifier(null);
  final ValueNotifier<int> _stableFramesNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _modelInitializingNotifier = ValueNotifier(true);

  bool _processing = false;
  bool _disposed = false;
  bool _navigating = false;
  bool _isGalleryLoading = false;
  XFile? _galleryFile;
  PalmLandmarkResult? _galleryResult;
  PalmLandmarkResult? _lastDetectedResult;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastLogTime = DateTime.now();
  int _frameCount = 0;
  bool _permissionDenied = false;
  bool _initError = false;
  Timer? _initTimeoutTimer;

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

      // ML 모델 서비스 생성 (즉시 반환 — 실제 플러그인 init은 warmUp에서)
      final modelFuture = HandLandmarkService.create();

      await ctrl.initialize();
      if (_disposed) { await ctrl.dispose(); return; }

      // 카메라 프리뷰 즉시 표시 + 스피너 렌더
      if (mounted) setState(() => _camera = ctrl);

      _handLandmark = await modelFuture;
      if (_disposed) return;

      // 프리뷰와 스피너가 최소 2프레임 렌더된 후 플러그인 초기화
      // warmUp()은 동기 블로킹이므로 프레임 렌더 후 호출해야 스피너가 보임
      final completer = Completer<void>();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          completer.complete();
        });
      });
      await completer.future;
      if (_disposed) return;

      _handLandmark!.warmUp(); // 여기서 GPU 플러그인 동기 init (블로킹 소비)
      if (_disposed) return;

      // 30초 타임아웃 — init이 첫 process()에서 풀리지 않으면 에러 상태
      _initTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && _modelInitializingNotifier.value) {
          setState(() => _initError = true);
        }
      });

      await ctrl.startImageStream(_onFrame);
    } catch (e) {
      debugPrint('[PalmCamera] init error: $e');
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  void _onFrame(CameraImage image) {
    if (_disposed || _navigating || _processing || _handLandmark == null || _camera == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessedAt).inMilliseconds < AppConst.frameThrottleMs) return;
    _lastProcessedAt = now;
    _processing = true;
    _processFrameAsync(image, now);
  }

  Future<void> _processFrameAsync(CameraImage image, DateTime frameTime) async {
    try {
      final result = await _handLandmark!.process(image, _camera!.description);
      if (_disposed) return;

      if (_modelInitializingNotifier.value) {
        _modelInitializingNotifier.value = false;
        _initTimeoutTimer?.cancel();
        _initTimeoutTimer = null;
      }

      final bool detected = result != null;
      if (detected) {
        _lastDetectedResult = result;
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value + 1).clamp(0, AppConst.stabilityFrames + 1);
      } else if (_stableFramesNotifier.value < AppConst.stabilityFrames) {
        _stableFramesNotifier.value =
            (_stableFramesNotifier.value - 2).clamp(0, AppConst.stabilityFrames + 1);
      }

      _frameCount++;
      if (frameTime.difference(_lastLogTime).inMilliseconds > 500) {
        _lastLogTime = frameTime;
        debugPrint('[PalmCamera] frames=$_frameCount stable=${_stableFramesNotifier.value} detected=$detected');
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
    setState(() { _galleryFile = null; _galleryResult = null; });
    try { await _camera?.startImageStream(_onFrame); } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    if (_handLandmark == null || _isGalleryLoading) return;

    try { await _camera?.stopImageStream(); } catch (_) {}
    setState(() => _isGalleryLoading = true);

    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted) return;

      if (file == null) {
        if (!_disposed) try { await _camera?.startImageStream(_onFrame); } catch (_) {}
        return;
      }

      final result = await _handLandmark!.processFile(file.path);

      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noPalmDetected)),
        );
        if (!_disposed) try { await _camera?.startImageStream(_onFrame); } catch (_) {}
        return;
      }

      setState(() {
        _galleryFile = file;
        _galleryResult = result;
      });
    } finally {
      if (mounted) setState(() => _isGalleryLoading = false);
    }
  }

  void _clearGallery() {
    setState(() {
      _galleryFile = null;
      _galleryResult = null;
    });
    if (!_disposed) try { _camera?.startImageStream(_onFrame); } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _initTimeoutTimer?.cancel();
    _camera?.stopImageStream().then((_) => _camera?.dispose());
    _handLandmark?.dispose();
    _landmarkNotifier.dispose();
    _stableFramesNotifier.dispose();
    _modelInitializingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_permissionDenied) return _buildPermissionDenied(context, l10n);

    final ctrl = _camera;
    final isReady = ctrl != null && ctrl.value.isInitialized;
    final locale = Localizations.localeOf(context).languageCode;
    final labels = keyHandLandmarkLabels(locale);

    if (_initError) return _buildInitError(context, l10n);

    final inGalleryMode = _galleryFile != null && _galleryResult != null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.palmReading,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (inGalleryMode)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              tooltip: 'Camera',
              onPressed: _clearGallery,
            ),
        ],
      ),
      body: inGalleryMode
          ? _buildGalleryPreview(context, l10n, labels)
          : (isReady
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Camera + hand overlay at correct aspect ratio, cropped to fill screen
                Builder(builder: (context) {
                  final c = ctrl;
                  final mq = MediaQuery.of(context);
                  final size = mq.size;
                  // CameraPreview internally uses 1/aspectRatio for portrait (sensor is landscape)
                  final isPortrait = mq.orientation == Orientation.portrait;
                  final cameraAspect = isPortrait ? (1.0 / c.value.aspectRatio) : c.value.aspectRatio;
                  final screenAspect = size.width / size.height;
                  final double coverW, coverH;
                  if (cameraAspect > screenAspect) {
                    coverH = size.height;
                    coverW = size.height * cameraAspect;
                  } else {
                    coverW = size.width;
                    coverH = size.width / cameraAspect;
                  }
                  return ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      minWidth: 0,
                      minHeight: 0,
                      maxWidth: coverW,
                      maxHeight: coverH,
                      child: SizedBox(
                        width: coverW,
                        height: coverH,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(c),
                            RepaintBoundary(
                              child: ValueListenableBuilder<PalmLandmarkResult?>(
                                valueListenable: _landmarkNotifier,
                                builder: (_, result, __) {
                                  if (result == null) return const SizedBox.shrink();
                                  return CustomPaint(
                                    painter: HandOverlayPainter(result: result, labels: labels),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // 엔진 초기화 중 전체화면 오버레이
                ValueListenableBuilder<bool>(
                  valueListenable: _modelInitializingNotifier,
                  builder: (_, initializing, __) {
                    if (!initializing) return const SizedBox.shrink();
                    return Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.72),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 48, height: 48,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l10n.aiEngineInitializing,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.aiEngineInitializingDesc,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // 손 감지 전 가이드 박스 (엔진 준비 후)
                ValueListenableBuilder<bool>(
                  valueListenable: _modelInitializingNotifier,
                  builder: (_, initializing, __) {
                    if (initializing) return const SizedBox.shrink();
                    return ValueListenableBuilder<PalmLandmarkResult?>(
                      valueListenable: _landmarkNotifier,
                      builder: (_, result, __) {
                        if (result != null) return const SizedBox.shrink();
                        return Center(
                          child: Container(
                            width: 240, height: 320,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30, width: 2),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.back_hand_outlined,
                                    color: Colors.white30, size: 48),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  l10n.palmGuide,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 164, left: 0, right: 0,
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _stableFramesNotifier,
                      builder: (_, stableFrames, __) => CameraStabilityCard(
                        progress: stableFrames / AppConst.stabilityFrames,
                        isStable: stableFrames >= AppConst.stabilityFrames,
                        isFace: false,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 88,
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
                          label: Text(l10n.palmViewResults),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 36,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: _isGalleryLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white60, strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _handLandmark != null ? _pickFromGallery : null,
                          icon: const Icon(Icons.photo_library_outlined,
                              color: Colors.white60, size: 18),
                          label: Text(
                            l10n.selectFromGallery,
                            style: const TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white))),
    );
  }

  Widget _buildGalleryPreview(
    BuildContext context,
    AppLocalizations l10n,
    Map<int, String> labels,
  ) {
    final file = _galleryFile!;
    final result = _galleryResult!;
    final imgAspect = result.frameWidth / result.frameHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: imgAspect,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(file.path), fit: BoxFit.fill),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: HandOverlayPainter(result: result, labels: labels),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 88,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          child: FilledButton.icon(
            onPressed: () => _goToResult(result),
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.palmViewResults),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          child: _isGalleryLoading
              ? const Center(
                  child: SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white60, strokeWidth: 2.5),
                  ),
                )
              : TextButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined,
                      color: Colors.white60, size: 18),
                  label: Text(
                    l10n.selectFromGallery,
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildInitError(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.palmReading,
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
              const Icon(Icons.error_outline, color: Colors.white54, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.aiEngineInitError,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _initError = false;
                    _modelInitializingNotifier.value = true;
                  });
                  _init();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.aiEngineRetry),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack,
                    style: const TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.palmReading,
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
              Text(l10n.palmPermissionDesc,
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

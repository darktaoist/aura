import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../data/gemma/gemma_service.dart';
import '../model_setup/model_config.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await Future.wait([
        _checkFirstRun(),
        Future.delayed(const Duration(milliseconds: 1200)),
      ]);

      if (!mounted) return;

      // Gemma 모델 유효성 검사 + 경로 재등록:
      //   hasActiveModel() 이 true 여도 경로가 디렉토리이면
      //   getActiveModel() 이 "Unsupported model format" 으로 실패한다.
      //   → 파일을 찾아 올바른 경로로 재등록한다.
      final modelReady = await _ensureModelReady();
      if (!mounted) return;

      if (!modelReady) {
        context.go('/model_setup');
        return;
      }

      // 모델이 준비됐으면 카메라 없는 지금 미리 로드 (메모리 여유 있을 때)
      // ignore: unused_result
      ref.read(gemmaServiceProvider.future).ignore();

      final isFirstRun = results[0] as bool;
      if (!mounted) return;
      context.go(isFirstRun ? '/language_select' : '/home');
    } catch (e) {
      // SharedPreferences 오류 등 — 안전하게 홈으로 이동
      if (mounted) context.go('/home');
    }
  }

  /// 기기에서 모델 파일(.litertlm)을 찾아 올바른 경로로 재등록한다.
  ///
  /// 0) URL 버전이 바뀐 경우 모든 기존 모델 파일을 삭제하고 재다운로드 유도.
  /// 1) 기기 전체를 스캔해 .litertlm 파일을 찾아 등록한다.
  /// 파일을 어디서도 찾지 못하면 false → model_setup 으로 이동.
  Future<bool> _ensureModelReady() async {
    // ── 0단계: URL 버전 체크 — 버전이 바뀌었으면 기존 파일 전체 삭제 ──────
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt('model_url_version') ?? 0;
    if (savedVersion < kModelUrlVersion) {
      debugPrint('[Splash] 모델 URL 버전 변경 ($savedVersion → $kModelUrlVersion) → 기존 파일 삭제');
      await deleteAllModelFiles();
      await prefs.setInt('model_url_version', kModelUrlVersion);
      return false;
    }

    // ── 1단계: 확장자 있는 모델 파일 스캔 ────────────────────────────────
    final dirs = await buildScanDirs();
    for (final dir in dirs) {
      try {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final e in d.listSync(followLinks: false)) {
          if (e is File &&
              kModelExtensions.any(e.path.toLowerCase().endsWith)) {
            debugPrint('[Splash] 모델 파일 발견: ${e.path}');

            if (!await isValidModelContent(e)) {
              debugPrint('[Splash] 유효하지 않은 파일 삭제: ${e.path}');
              try { await e.delete(); } catch (_) {}
              continue;
            }

            try {
              final config = configForFile(e.path);
              await FlutterGemma.installModel(
                modelType: config.modelType,
                fileType: config.fileType,
              ).fromFile(e.path).install();
              debugPrint('[Splash] 모델 등록 완료 → ${e.path}');
              return true;
            } catch (regErr) {
              debugPrint('[Splash] 모델 재등록 실패: $regErr');
              return false;
            }
          }
        }
      } catch (_) {}
    }

    debugPrint('[Splash] 모델 파일 없음 → model_setup');
    return false;
  }

  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('locale');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.brandGradient.createShader(bounds),
              child: const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.brandGradient.createShader(bounds),
              child: Text(
                'Aura',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '관상 · 손금 AI 분석',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

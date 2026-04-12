import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

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

      // Gemma 모델 미설치 → 모델 셋업 화면으로 이동 (홈과의 루프 방지)
      if (!FlutterGemma.hasActiveModel()) {
        context.go('/model_setup');
        return;
      }

      final isFirstRun = results[0] as bool;
      context.go(isFirstRun ? '/language_select' : '/home');
    } catch (e) {
      // SharedPreferences 오류 등 — 안전하게 홈으로 이동
      if (mounted) context.go('/home');
    }
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

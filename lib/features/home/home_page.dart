import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_notifier.dart';
import '../model_setup/model_config.dart';
import '../model_setup/model_setup_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(modelSetupNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '오늘의 분석',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ReadingCard(
                    title: '관상 보기',
                    description: '얼굴 특징으로 읽는 당신의 운명',
                    icon: Icons.face_retouching_natural,
                    onTap: () => context.push('/face/camera'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ReadingCard(
                    title: '손금 보기',
                    description: '손바닥 선으로 읽는 당신의 미래',
                    icon: Icons.back_hand_outlined,
                    onTap: () => context.push('/palm/camera'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ConsultationCard(ref: ref),
                ],
              ),
            ),
          ),
          // 모델 다운로드 진행 배너
          if (setupState.isDownloading)
            _ModelDownloadBanner(
              progress: setupState.progress,
              modelSizeGb: kDefaultModel.sizeGb,
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authNotifierProvider).isLoggedIn;
    return AppBar(
      title: ShaderMask(
        shaderCallback: (b) => AppColors.brandGradient.createShader(b),
        child: const Text(
          'Aura',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (val) {
            switch (val) {
              case 'login':
                context.push('/auth');
              case 'logout':
                ref.read(authNotifierProvider.notifier).signOut();
              case 'settings':
                context.push('/settings');
              case 'history':
                context.push('/history');
              case 'terms':
                context.push('/terms');
              case 'privacy':
                context.push('/privacy');
            }
          },
          itemBuilder: (_) => [
            if (!isLoggedIn)
              const PopupMenuItem(value: 'login',   child: Text('로그인'))
            else
              const PopupMenuItem(value: 'logout',  child: Text('로그아웃')),
            const PopupMenuItem(value: 'history',  child: Text('분석 기록')),
            const PopupMenuItem(value: 'settings', child: Text('설정')),
            const PopupMenuItem(value: 'terms',    child: Text('이용약관')),
            const PopupMenuItem(value: 'privacy',  child: Text('개인정보처리방침')),
          ],
        ),
      ],
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authNotifierProvider).isLoggedIn;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            context.push('/auth');
          } else {
            context.push('/consultation');
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isLoggedIn
                      ? AppColors.brandGradient
                      : LinearGradient(
                          colors: [
                            cs.outlineVariant,
                            cs.outlineVariant,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상담 이어가기',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isLoggedIn
                          ? '분석 결과를 더 깊이 알아보세요'
                          : '로그인이 필요합니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelDownloadBanner extends StatelessWidget {
  const _ModelDownloadBanner({
    required this.progress,
    required this.modelSizeGb,
  });

  final int progress;
  final double modelSizeGb;

  @override
  Widget build(BuildContext context) {
    final downloaded = (progress / 100 * modelSizeGb).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI 모델 준비 중...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$downloaded GB / ${modelSizeGb.toStringAsFixed(1)} GB',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class LanguageSelectPage extends StatelessWidget {
  const LanguageSelectPage({super.key});

  static const _languages = [
    (code: 'ko', label: '한국어',  flag: '🇰🇷'),
    (code: 'en', label: 'English', flag: '🇺🇸'),
    (code: 'ja', label: '日本語',  flag: '🇯🇵'),
    (code: 'zh', label: '中文',    flag: '🇨🇳'),
  ];

  Future<void> _select(BuildContext context, String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              ShaderMask(
                shaderCallback: (b) => AppColors.brandGradient.createShader(b),
                child: Text(
                  'Aura',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '사용할 언어를 선택하세요\nSelect your language',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...(_languages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LanguageCard(
                    flag: lang.flag,
                    label: lang.label,
                    onTap: () => _select(context, lang.code),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flag,
    required this.label,
    required this.onTap,
  });

  final String flag;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

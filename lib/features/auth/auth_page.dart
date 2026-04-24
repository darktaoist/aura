import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'auth_notifier.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, this.returnPath});

  final String? returnPath;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.isLoggedIn && context.mounted) context.pop();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              ShaderMask(
                shaderCallback: (b) => AppColors.brandGradient.createShader(b),
                child: const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aura',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.loginPrompt,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _AgreementCheckbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                onTermsTap: () => context.push('/terms'),
                onPrivacyTap: () => context.push('/privacy'),
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacing.lg),
              _AuthButton(
                label: l10n.loginWithGoogle,
                icon: Icons.g_mobiledata,
                onPressed: _agreed && !isLoading ? _signInWithGoogle : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _AuthButton(
                label: l10n.loginWithKakao,
                icon: Icons.chat_bubble_outline,
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black87,
                onPressed: _agreed && !isLoading ? _signInWithKakao : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _signInWithKakao() async {
    await ref.read(authNotifierProvider.notifier).signInWithKakao();
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.l10n,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: Wrap(
            children: [
              Text(l10n.agreePrefix),
              GestureDetector(
                onTap: onTermsTap,
                child: Text(
                  l10n.termsOfService,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(l10n.agreeConnector),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text(
                  l10n.privacyPolicy,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

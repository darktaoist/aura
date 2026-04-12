import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.returnPath});

  final String? returnPath;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _agreed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
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
              // 로고
              ShaderMask(
                shaderCallback: (b) => AppColors.brandGradient.createShader(b),
                child: const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aura',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '결과를 저장하려면 로그인하세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 약관 동의
              _AgreementCheckbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                onTermsTap: () => context.push('/terms'),
                onPrivacyTap: () => context.push('/privacy'),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Google 로그인
              _AuthButton(
                label: 'Google로 로그인',
                icon: Icons.g_mobiledata,
                onPressed: _agreed && !_isLoading ? _signInWithGoogle : null,
              ),
              const SizedBox(height: AppSpacing.md),
              // Kakao 로그인
              _AuthButton(
                label: '카카오로 로그인',
                icon: Icons.chat_bubble_outline,
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black87,
                onPressed: _agreed && !_isLoading ? _signInWithKakao : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  '건너뛰기',
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
    setState(() => _isLoading = true);
    // TODO Phase 7: supabase.auth.signInWithOAuth(OAuthProvider.google)
    setState(() => _isLoading = false);
  }

  Future<void> _signInWithKakao() async {
    setState(() => _isLoading = true);
    // TODO Phase 7: kakao_flutter_sdk → Edge Function kakao-auth → Supabase JWT
    setState(() => _isLoading = false);
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
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: Wrap(
            children: [
              const Text('동의합니다: '),
              GestureDetector(
                onTap: onTermsTap,
                child: Text(
                  '이용약관',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(' 및 '),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text(
                  '개인정보처리방침',
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

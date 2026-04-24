import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../home/widgets/aura_wordmark.dart';
import 'auth_notifier.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, this.returnPath});
  final String? returnPath;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  bool get _canSignIn => _agreeTerms && _agreePrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.isLoggedIn && context.mounted) context.pop();
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 radial 워시
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.7),
                      radius: 1.0,
                      colors: [
                        theme.colorScheme.primary.withValues(
                          alpha: theme.brightness == Brightness.dark ? 0.09 : 0.06,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl * 1.5),

                  // 브랜드 블록
                  const Center(child: AuraWordmark(size: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: aura.onSurfaceMuted,
                    ),
                  ),

                  const Spacer(),

                  // 동의 블록
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: aura.surfaceContainer,
                      border: Border.all(color: aura.cardBorder, width: 1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        _ConsentRow(
                          value: _agreeTerms,
                          label: l10n.authAgreeTerms,
                          onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                          onLink: () => context.push('/terms'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ConsentRow(
                          value: _agreePrivacy,
                          label: l10n.authAgreePrivacy,
                          onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                          onLink: () => context.push('/privacy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Google 로그인
                  _OAuthButton(
                    enabled: _canSignIn && !isLoading,
                    label: l10n.authSignInGoogle,
                    iconBuilder: (_) => const _GoogleGlyph(size: 18),
                    onTap: () =>
                        ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Kakao 로그인
                  _OAuthButton(
                    enabled: _canSignIn && !isLoading,
                    label: l10n.loginWithKakao,
                    iconBuilder: (_) => const Icon(
                      Icons.chat_bubble_rounded,
                      size: 18,
                      color: Color(0xFF3A1D1D),
                    ),
                    backgroundColor: const Color(0xFFFEE500),
                    labelColor: const Color(0xFF3A1D1D),
                    onTap: () =>
                        ref.read(authNotifierProvider.notifier).signInWithKakao(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 게스트 진입
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(
                      l10n.authContinueGuest,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: aura.onSurfaceMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // 로딩 오버레이
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.onLink,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 22, height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            IconButton(
              onPressed: onLink,
              icon: Icon(Icons.chevron_right, size: 18, color: aura.onSurfaceMuted),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.enabled,
    required this.label,
    required this.iconBuilder,
    required this.onTap,
    this.backgroundColor,
    this.labelColor,
  });

  final bool enabled;
  final String label;
  final Widget Function(BuildContext) iconBuilder;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final bgColor = backgroundColor ?? aura.surfaceContainer;
    final fgColor = labelColor ??
        (enabled ? theme.colorScheme.onSurface : aura.onSurfaceSubtle);

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: enabled ? bgColor : bgColor.withValues(alpha: 0.5),
          side: BorderSide(color: aura.cardBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(context),
            const SizedBox(width: AppSpacing.sm + 2),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google 로고 — 네이티브 패키지 없이 CustomPainter로 구현.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  static const _colors = [
    Color(0xFF4285F4),
    Color(0xFFEA4335),
    Color(0xFFFBBC05),
    Color(0xFF34A853),
  ];
  static const _starts = [-1.5708, -3.1416, 1.5708, 0.0];

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final p = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromCircle(center: center, radius: r);

    for (int i = 0; i < 4; i++) {
      p.color = _colors[i];
      canvas.drawArc(rect, _starts[i], 1.5708, true, p);
    }
    p.color = Colors.white;
    canvas.drawCircle(center, r * 0.45, p);
    p.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(r, r * 0.85, r, r * 0.3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

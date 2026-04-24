// lib/features/auth/auth_page.dart
//
// 로그인 / 가입 화면 — OAuth 버튼(Google/Apple) + 동의 체크박스 + 게스트 진입.
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • 상단 Aura 워드마크 + 브랜드 태그라인
// • OAuth 버튼: 브랜드 중립 스타일(흰 카드 + 플랫폼 로고 + 라벨)
// • 동의 체크박스: 약관/개인정보 링크 tappable, 미동의 시 OAuth 비활성
// • 하단 "둘러보기"(게스트) 링크
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'providers/auth_providers.dart'; // 기존 (가정)
import '../home/widgets/aura_wordmark.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 워시
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.7),
                      radius: 1.0,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.08),
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
                    l10n.authTagline, // TODO: add key 'authTagline'
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
                          label: l10n.authAgreeTerms, // TODO: add key
                          onChanged: (v) =>
                              setState(() => _agreeTerms = v ?? false),
                          onLink: () => context.push('/legal/terms'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ConsentRow(
                          value: _agreePrivacy,
                          label: l10n.authAgreePrivacy, // TODO: add key
                          onChanged: (v) =>
                              setState(() => _agreePrivacy = v ?? false),
                          onLink: () => context.push('/legal/privacy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // OAuth 버튼
                  _OAuthButton(
                    enabled: _canSignIn,
                    label: l10n.authSignInGoogle, // TODO: add key
                    iconBuilder: (ctx) => const _GoogleGlyph(size: 18),
                    onTap: () =>
                        ref.read(authProvider.notifier).signInGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OAuthButton(
                    enabled: _canSignIn,
                    label: l10n.authSignInApple, // TODO: add key
                    iconBuilder: (ctx) => Icon(
                      Icons.apple,
                      size: 20,
                      color: ctx.auraColors.onSurfaceMuted,
                    ),
                    onTap: () =>
                        ref.read(authProvider.notifier).signInApple(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 게스트
                  TextButton(
                    onPressed: () =>
                        ref.read(authProvider.notifier).continueAsGuest(),
                    child: Text(l10n.authContinueGuest), // TODO: add key
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
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
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: onLink,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: aura.onSurfaceMuted,
              ),
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
  });
  final bool enabled;
  final String label;
  final Widget Function(BuildContext) iconBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: aura.surfaceContainer,
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
              style: theme.textTheme.labelLarge?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : aura.onSurfaceSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google 로고를 외부 패키지 없이 네 컬러 원 조합으로 대체 (금지: 신규 패키지).
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
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    // 네 사분면 색
    const colors = [
      Color(0xFF4285F4), // top-right blue
      Color(0xFFEA4335), // top-left red
      Color(0xFFFBBC05), // bottom-left yellow
      Color(0xFF34A853), // bottom-right green
    ];
    // 회전 각도
    final starts = [ -1.57, -3.14, 1.57, 0.0 ];
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      p.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        starts[i], 1.57, true, p,
      );
    }
    // 중앙 hole
    p.color = Colors.white;
    canvas.drawCircle(center, r * 0.45, p);
    // 우측 사각형 (Google 'G' 느낌)
    p.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(r, r * 0.85, r, r * 0.3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

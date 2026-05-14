import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  bool get _canSignIn => _agreeTerms && _agreePrivacy;

  void _showConsentHint(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.authTermsNotice,
          style: GoogleFonts.notoSansKr(fontSize: 12),
        ),
        backgroundColor: AppColors.bg3,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.isLoggedIn && context.mounted) {
        context.pop();
      } else if (next.error != null &&
          prev?.error != next.error &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!,
                style: GoogleFonts.notoSansKr(fontSize: 12)),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Stack(
          children: [
            // Radial glow
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.5),
                      radius: 0.85,
                      colors: [
                        AppColors.gold.withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Close button (top right)
            Positioned(
              top: 8, right: 8,
              child: IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.ivoryDim),
                onPressed: isLoading ? null : () => context.pop(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo ring
                  Center(
                    child: SizedBox(
                      width: 88, height: 88,
                      child: CustomPaint(painter: _AuthRingPainter()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 17, fontWeight: FontWeight.w300,
                      color: AppColors.ivory, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authSignInSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12, color: AppColors.ivoryDim, height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 60,
                      child: CustomPaint(painter: _SmallOrnamentPainter()),
                    ),
                  ),

                  const Spacer(),

                  // 동의 블록
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      border: Border.all(color: AppColors.hair, width: 1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
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
                    onDisabledTap: () => _showConsentHint(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Kakao 로그인
                  _OAuthButton(
                    enabled: _canSignIn && !isLoading,
                    label: l10n.loginWithKakao,
                    iconBuilder: (_) => const _KakaoMark(),
                    backgroundColor: const Color(0xFFFEE500),
                    labelColor: const Color(0xFF1A0E0E),
                    isKakao: true,
                    onTap: () =>
                        ref.read(authNotifierProvider.notifier).signInWithKakao(),
                    onDisabledTap: () => _showConsentHint(context),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 나중에 하기
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      child: Text(
                        l10n.authContinueGuest,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12, color: AppColors.ivoryDim,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.hair,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Terms notice
                  Text(
                    l10n.authTermsNotice,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10, color: AppColors.ivoryFaint, height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

            // 로딩 오버레이
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x55000000),
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
    this.onDisabledTap,
    this.backgroundColor,
    this.labelColor,
    this.isKakao = false,
  });

  final bool enabled;
  final String label;
  final Widget Function(BuildContext) iconBuilder;
  final VoidCallback onTap;
  final VoidCallback? onDisabledTap;
  final Color? backgroundColor;
  final Color? labelColor;
  final bool isKakao;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.transparent;
    final fgColor = labelColor ?? AppColors.ivory;
    final borderColor = isKakao ? Colors.transparent : AppColors.ivoryMid;

    return SizedBox(
      height: 50,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            onTap: enabled ? onTap : onDisabledTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconBuilder(context),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Text(
                    label,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      letterSpacing: 0.5, color: fgColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

// ── Auth ring logo ────────────────────────────────────────────────────────────

class _AuthRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = cx - 2;
    final inner = cx - 9;

    final gPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // gradient ring via shader
    gPaint.shader = const SweepGradient(
      colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outer));
    canvas.drawCircle(Offset(cx, cy), outer, gPaint);

    gPaint.shader = null;
    gPaint.color = AppColors.hair;
    gPaint.strokeWidth = 0.5;
    canvas.drawCircle(Offset(cx, cy), inner, gPaint);

    // "A" text
    final tp = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          fontFamily: 'NotoSerifKR',
          fontSize: size.width * 0.35,
          color: AppColors.ivory,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_AuthRingPainter _) => false;
}

class _SmallOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final p = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.4)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, cy), Offset(20, cy), p);
    canvas.drawLine(Offset(40, cy), Offset(size.width, cy), p);

    final dp = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(30, 0)
      ..lineTo(35, cy)
      ..lineTo(30, size.height)
      ..lineTo(25, cy)
      ..close();
    canvas.drawPath(path, dp);
  }

  @override
  bool shouldRepaint(_SmallOrnamentPainter _) => false;
}

class _KakaoMark extends StatelessWidget {
  const _KakaoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18, height: 18,
      child: CustomPaint(painter: _KakaoPainter()),
    );
  }
}

class _KakaoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A0E0E)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height * 0.44;
    final rx = size.width * 0.46;
    final ry = size.height * 0.38;

    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy), width: rx * 2, height: ry * 2,
    ));

    // tail
    final tail = Path()
      ..moveTo(cx - rx * 0.2, cy + ry * 0.7)
      ..quadraticBezierTo(cx - rx * 0.4, cy + ry * 1.4,
          cx - rx * 0.5, cy + ry * 1.7)
      ..quadraticBezierTo(cx + rx * 0.1, cy + ry * 1.2,
          cx + rx * 0.2, cy + ry * 0.8);
    tail.close();
    canvas.drawPath(path, p);
    canvas.drawPath(tail, p..color = const Color(0xFFFEE500));

    // speech bubble effect
    final bg = Paint()
      ..color = const Color(0xFFFEE500)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bg);
    canvas.drawPath(tail, bg);

    // icon marks (simplified)
    final ip = Paint()
      ..color = const Color(0xFF1A0E0E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 3, cy - 2), Offset(cx - 3, cy + 3), ip);
    canvas.drawLine(Offset(cx + 1, cy - 3), Offset(cx - 1, cy + 1), ip);
    canvas.drawLine(Offset(cx + 3, cy - 2), Offset(cx + 3, cy + 3), ip);
  }

  @override
  bool shouldRepaint(_KakaoPainter _) => false;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class HomeHeroCard extends StatefulWidget {
  const HomeHeroCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.showGuestBadge = false,
    this.sealChar = '相',
    this.tall = false,
    this.todayBadge,
    this.metaLabel,
    this.silhouette,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool showGuestBadge;
  final String sealChar;
  final bool tall;
  final String? todayBadge;
  final String? metaLabel;
  final Widget? silhouette;

  @override
  State<HomeHeroCard> createState() => _HomeHeroCardState();
}

class _HomeHeroCardState extends State<HomeHeroCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.tall ? 270.0 : 180.0;
    final hasBadge = widget.todayBadge != null;
    final accent = widget.accent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        height: h,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: hasBadge
                ? accent.withValues(alpha: 0.5)
                : AppColors.hair,
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 0.6, 1],
            colors: [
              _hslSurface(accent, 0.9),
              _hslSurface(accent, 0.95),
              AppColors.bg0,
            ],
          ),
          boxShadow: [
            if (hasBadge || _hovered)
              BoxShadow(
                color: accent.withValues(alpha: _hovered ? 0.35 : 0.18),
                blurRadius: _hovered ? 32 : 20,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Stack(
            children: [
              // radial glow behind silhouette
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0.6, 0),
                  child: Container(
                    width: h * 1.2,
                    height: h * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: _hovered ? 0.32 : 0.20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Silhouette / SVG line art
              if (widget.silhouette != null)
                Positioned(
                  right: widget.tall ? -28 : -36,
                  top: widget.tall ? -8 : -16,
                  bottom: widget.tall ? -8 : -16,
                  width: widget.tall ? 240 : 190,
                  child: Opacity(
                    opacity: _hovered ? 1.0 : 0.95,
                    child: widget.silhouette!,
                  ),
                ),

              // Seal stamp
              Positioned(
                top: 12, right: 12,
                child: _SealStamp(
                  char: widget.sealChar,
                  size: widget.tall ? 38 : 30,
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta chips row
                    Row(
                      children: [
                        if (hasBadge) ...[
                          _MetaChip(
                            label: widget.todayBadge!,
                            color: AppColors.goldLight,
                            bgColor: accent.withValues(alpha: 0.35),
                            dot: true,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (widget.metaLabel != null)
                          _MetaChip(
                            label: widget.metaLabel!,
                            color: AppColors.ivoryDim,
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Label (大 title)
                    Text(
                      widget.label,
                      style: GoogleFonts.notoSerifKr(
                        fontSize: widget.tall ? 34 : 24,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ivory,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.description,
                      style: GoogleFonts.notoSansKr(
                        fontSize: widget.tall ? 12 : 11,
                        color: AppColors.ivoryDim,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // CTA line
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12, letterSpacing: 0.5,
                            color: AppColors.goldLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 18, height: 1,
                          color: AppColors.goldLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _hslSurface(Color accent, double blend) {
    // blend toward bg1 so the card has a dark tinted gradient
    return Color.lerp(
      accent.withValues(alpha: 0.18),
      AppColors.bg1,
      blend,
    )!;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.color,
    this.bgColor,
    this.dot = false,
  });

  final String label;
  final Color color;
  final Color? bgColor;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9, letterSpacing: 1.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SealStamp extends StatelessWidget {
  const _SealStamp({required this.char, required this.size});
  final String char;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: const Color(0x808c2e20),
        border: Border.all(color: const Color(0x808c2e20), width: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          char,
          style: GoogleFonts.notoSerifKr(
            fontSize: size * 0.5,
            color: AppColors.ivory.withValues(alpha: 0.85),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── SVG Silhouettes ───────────────────────────────────────────────────────────

class FaceSilhouette extends StatelessWidget {
  const FaceSilhouette({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FacePainter());
  }
}

class PalmSilhouette extends StatelessWidget {
  const PalmSilhouette({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PalmPainter());
  }
}

class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 300;
    final scaleY = size.height / 380;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final face = Path()
      ..moveTo(195, 40)
      ..cubicTo(240, 55, 260, 100, 258, 150)
      ..cubicTo(257, 180, 252, 210, 245, 240)
      ..cubicTo(240, 260, 232, 280, 220, 295)
      ..cubicTo(210, 308, 195, 318, 175, 322)
      ..lineTo(175, 355)
      ..lineTo(125, 355)
      ..lineTo(125, 328)
      ..cubicTo(110, 325, 95, 315, 85, 300)
      ..cubicTo(75, 285, 68, 265, 62, 240)
      ..cubicTo(56, 215, 53, 190, 53, 165)
      ..cubicTo(54, 110, 80, 60, 130, 42)
      ..cubicTo(150, 35, 175, 34, 195, 40);
    canvas.drawPath(face, p);

    // eye brows
    canvas.drawLine(const Offset(95, 155), const Offset(142, 155), p..color = AppColors.ivory.withValues(alpha: 0.42));
    canvas.drawLine(const Offset(175, 155), const Offset(222, 155), p);
    // nose
    final nose = Path()
      ..moveTo(158, 170)
      ..lineTo(152, 220)
      ..lineTo(160, 235)
      ..lineTo(170, 230);
    canvas.drawPath(nose, p);
    // mouth
    final mouth = Path()
      ..moveTo(135, 265)
      ..cubicTo(150, 272, 175, 272, 190, 265);
    canvas.drawPath(mouth, p);
    // eyes
    canvas.drawOval(Rect.fromCenter(center: const Offset(118, 163), width: 22, height: 14), p);
    canvas.drawOval(Rect.fromCenter(center: const Offset(182, 163), width: 22, height: 14), p);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FacePainter _) => false;
}

class _PalmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 300;
    final scaleY = size.height / 380;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final hand = Path()
      ..moveTo(80, 360)
      ..lineTo(80, 260)
      ..cubicTo(70, 240, 60, 215, 58, 190)
      ..cubicTo(57, 170, 64, 155, 78, 155)
      ..cubicTo(84, 155, 90, 160, 92, 170)
      ..lineTo(95, 220)
      ..lineTo(95, 140)
      ..cubicTo(95, 125, 105, 115, 118, 115)
      ..cubicTo(128, 115, 136, 125, 136, 138)
      ..lineTo(136, 215)
      ..lineTo(140, 75)
      ..cubicTo(140, 60, 150, 50, 162, 50)
      ..cubicTo(174, 50, 184, 60, 184, 75)
      ..lineTo(184, 215)
      ..lineTo(188, 100)
      ..cubicTo(188, 86, 198, 76, 210, 76)
      ..cubicTo(222, 76, 232, 86, 232, 100)
      ..lineTo(232, 225)
      ..cubicTo(232, 230, 235, 230, 237, 225)
      ..lineTo(255, 165)
      ..cubicTo(260, 152, 275, 150, 283, 160)
      ..cubicTo(290, 168, 290, 180, 285, 195)
      ..lineTo(250, 295)
      ..cubicTo(245, 320, 230, 340, 210, 352)
      ..lineTo(210, 360);
    canvas.drawPath(hand, p..strokeWidth = 1.2);

    // palm lines
    final heartLine = Path()
      ..moveTo(90, 170)
      ..cubicTo(130, 155, 175, 152, 220, 162);
    canvas.drawPath(heartLine, p..strokeWidth = 1.5);

    final headLine = Path()
      ..moveTo(100, 205)
      ..cubicTo(140, 218, 195, 218, 230, 205);
    canvas.drawPath(headLine, p..strokeWidth = 1.4);

    final lifeLine = Path()
      ..moveTo(210, 130)
      ..cubicTo(180, 160, 140, 200, 115, 260)
      ..cubicTo(105, 290, 100, 320, 102, 350);
    canvas.drawPath(lifeLine, p..strokeWidth = 1.5);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PalmPainter _) => false;
}

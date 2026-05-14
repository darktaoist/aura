import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class AuraWordmark extends StatelessWidget {
  const AuraWordmark({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 1.1,
          height: size * 1.1,
          child: CustomPaint(painter: _RingLogoPainter()),
        ),
        SizedBox(width: size * 0.4),
        Text(
          'Aura',
          style: GoogleFonts.notoSerifKr(
            fontSize: size,
            fontWeight: FontWeight.w400,
            color: AppColors.ivory,
            letterSpacing: size * 0.14,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _RingLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    p.color = AppColors.gold.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cx, cy), size.width / 2 - 1, p);
    p.color = AppColors.gold.withValues(alpha: 0.5);
    p.strokeWidth = 0.5;
    canvas.drawCircle(Offset(cx, cy), size.width / 2 - 4, p);
    canvas.drawCircle(
      Offset(cx, cy), 2,
      Paint()..color = AppColors.gold..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RingLogoPainter _) => false;
}

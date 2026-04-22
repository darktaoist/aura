import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/palm_result.dart';
import '../../../../../domain/physiognomy/hand_connections.dart';

class HandOverlayPainter extends CustomPainter {
  const HandOverlayPainter({required this.result});

  final PalmLandmarkResult result;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkeleton(canvas, size);
    _drawKeyPoints(canvas, size);
  }

  void _drawSkeleton(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayMesh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final lm = result.landmarks;
    for (final (a, b) in kHandConnections) {
      if (a >= lm.length || b >= lm.length) continue;
      canvas.drawLine(
        Offset(lm[a].x * size.width, lm[a].y * size.height),
        Offset(lm[b].x * size.width, lm[b].y * size.height),
        paint,
      );
    }
  }

  void _drawKeyPoints(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.overlayKeyPoint
      ..style = PaintingStyle.fill;

    const labelStyle = TextStyle(
      color: AppColors.overlayKeyLabel,
      fontSize: 9,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
    );

    for (final entry in kKeyHandLandmarks.entries) {
      final idx = entry.value;
      if (idx >= result.landmarks.length) continue;

      final lm = result.landmarks[idx];
      final x = lm.x * size.width;
      final y = lm.y * size.height;

      canvas.drawCircle(Offset(x, y), 5.0, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 6, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant HandOverlayPainter old) =>
      !identical(old.result, result);
}

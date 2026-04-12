import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/landmark_result.dart';
import '../../../../../domain/physiognomy/landmark_index.dart';

class LandmarkOverlayPainter extends CustomPainter {
  const LandmarkOverlayPainter({required this.result});

  final FaceLandmarkResult result;

  @override
  void paint(Canvas canvas, Size size) {
    _drawMesh(canvas, size);
    _drawKeyPoints(canvas, size);
  }

  void _drawMesh(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayMesh
      ..style = PaintingStyle.fill;

    for (final lm in result.landmarks) {
      canvas.drawCircle(
        Offset(lm.x.clamp(0.0, 1.0) * size.width,
               lm.y.clamp(0.0, 1.0) * size.height),
        1.6,
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

    for (final entry in kKeyLandmarks.entries) {
      final idx = entry.value;
      if (idx >= result.landmarks.length) continue;

      final lm = result.landmarks[idx];
      final x = lm.x.clamp(0.0, 1.0) * size.width;
      final y = lm.y.clamp(0.0, 1.0) * size.height;

      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 5, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant LandmarkOverlayPainter old) =>
      !identical(old.result, result);
}

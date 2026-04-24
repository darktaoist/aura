import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/palm_result.dart';

class HandOverlayPainter extends CustomPainter {
  const HandOverlayPainter({required this.result, required this.labels});

  final PalmLandmarkResult result;
  /// index → localized label (from keyHandLandmarkLabels(locale))
  final Map<int, String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawBones(canvas, size);
    _drawKeyPoints(canvas, size);
  }

  // 손바닥 격자 (가로선·대각선) — 얇은 반투명
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayMesh.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final lm = result.landmarks;
    // 가로선 (관절 행 연결) — 손가락 뼈 제외, 끝마디·대각선 생략
    const gridOnly = [
      // MCP 행
      (5, 9), (9, 13), (13, 17),
      // PIP 행
      (6, 10), (10, 14), (14, 18),
      // 손바닥 외곽
      (1, 17), (1, 5), (2, 5), (5, 17),
    ];

    for (final (a, b) in gridOnly) {
      if (a >= lm.length || b >= lm.length) continue;
      canvas.drawLine(
        Offset(lm[a].x * size.width, lm[a].y * size.height),
        Offset(lm[b].x * size.width, lm[b].y * size.height),
        paint,
      );
    }
  }

  // 손가락 뼈대 — 굵고 선명하게
  void _drawBones(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayMesh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final lm = result.landmarks;
    const bones = [
      (0, 1), (1, 2), (2, 3), (3, 4),
      (0, 5), (5, 6), (6, 7), (7, 8),
      (0, 9), (9, 10), (10, 11), (11, 12),
      (0, 13), (13, 14), (14, 15), (15, 16),
      (0, 17), (17, 18), (18, 19), (19, 20),
    ];

    for (final (a, b) in bones) {
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

    for (final entry in labels.entries) {
      final idx = entry.key;
      if (idx >= result.landmarks.length) continue;

      final lm = result.landmarks[idx];
      final x = lm.x * size.width;
      final y = lm.y * size.height;

      canvas.drawCircle(Offset(x, y), 5.0, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: entry.value, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 6, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant HandOverlayPainter old) =>
      !identical(old.result, result) || old.labels != labels;
}

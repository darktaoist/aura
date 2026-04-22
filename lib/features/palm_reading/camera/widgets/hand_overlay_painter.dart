import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/palm_result.dart';
import '../../../../../domain/physiognomy/hand_connections.dart';

class HandOverlayPainter extends CustomPainter {
  const HandOverlayPainter({required this.result});

  final PalmLandmarkResult result;

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
    // 가로선 (관절 행 연결) + 대각선만 선별 — 손가락 뼈 제외
    const gridOnly = [
      // MCP 행
      (5, 9), (9, 13), (13, 17),
      // PIP 행
      (6, 10), (10, 14), (14, 18),
      // DIP 행
      (7, 11), (11, 15), (15, 19),
      // 끝마디 행
      (8, 12), (12, 16), (16, 20),
      // 손바닥 외곽
      (1, 17), (1, 5), (2, 5), (5, 17),
      // 대각선
      (5, 10), (6, 9),
      (9, 14), (10, 13),
      (13, 18), (14, 17),
      (5, 13), (9, 17),
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

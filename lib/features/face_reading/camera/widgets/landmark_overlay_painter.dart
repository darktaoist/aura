import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/landmark_result.dart';
import '../../../../../domain/physiognomy/face_mesh_connections.dart';

class LandmarkOverlayPainter extends CustomPainter {
  const LandmarkOverlayPainter({required this.result, required this.labels});

  final FaceLandmarkResult result;
  /// index → localized label (from keyLandmarkLabels(locale))
  final Map<int, String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    _drawMeshLines(canvas, size);
    _drawKeyPoints(canvas, size);
  }

  // ── 선 연결 (face mesh wireframe) ──────────────────────────────────────────
  void _drawMeshLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayMesh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final lm = result.landmarks;
    for (final (a, b) in kFaceMeshConnections) {
      if (a >= lm.length || b >= lm.length) continue;
      canvas.drawLine(
        Offset(lm[a].x * size.width, lm[a].y * size.height),
        Offset(lm[b].x * size.width, lm[b].y * size.height),
        paint,
      );
    }
  }

  // ── 관상 핵심 17점 (색 점 + 라벨) ──────────────────────────────────────────
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

      canvas.drawCircle(Offset(x, y), 4.0, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: entry.value, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 5, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant LandmarkOverlayPainter old) =>
      !identical(old.result, result) || old.labels != labels;
}

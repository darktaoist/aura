import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// 관상·손금 카메라 공통 — 하단 인식 상태 카드.
/// AnimationController를 최소화해 카메라 처리 성능 유지.
class CameraStabilityCard extends StatelessWidget {
  const CameraStabilityCard({
    super.key,
    required this.progress,
    required this.isStable,
    required this.isFace,
  });

  final double progress;
  final bool isStable;
  final bool isFace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String message;
    final IconData icon;
    final Color iconColor;
    final bool showBar;

    if (isStable) {
      message = l10n.cameraGuideDone;
      icon = Icons.check_circle_rounded;
      iconColor = AppColors.success;
      showBar = false;
    } else if (progress > 0) {
      message = l10n.cameraGuideScanning;
      icon = isFace ? Icons.face_retouching_natural : Icons.back_hand;
      iconColor = AppColors.seedDark;
      showBar = true;
    } else {
      message = isFace ? l10n.cameraGuideAlign : l10n.cameraGuideAlignHand;
      icon = isFace
          ? Icons.face_retouching_natural_outlined
          : Icons.back_hand_outlined;
      iconColor = Colors.white60;
      showBar = false;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isStable
              ? AppColors.success.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.seedDark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';

/// 3초 안정 감지 진행바
class StabilityIndicator extends StatelessWidget {
  const StabilityIndicator({
    super.key,
    required this.progress,   // 0.0 ~ 1.0
    required this.isStable,
  });

  final double progress;
  final bool isStable;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.overlayStatusBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isStable ? Icons.check_circle : Icons.face_retouching_natural,
                color: isStable ? Colors.greenAccent : Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isStable
                    ? AppLocalizations.of(context)!.stabilityDone
                    : AppLocalizations.of(context)!.stabilizing,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          if (!isStable) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

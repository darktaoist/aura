import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HandStabilityIndicator extends StatelessWidget {
  const HandStabilityIndicator({
    super.key,
    required this.progress,
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
                isStable ? Icons.check_circle : Icons.back_hand_outlined,
                color: isStable ? Colors.greenAccent : Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isStable ? '손 특이점 추출 완료' : '손을 안정적으로 유지해 주세요',
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

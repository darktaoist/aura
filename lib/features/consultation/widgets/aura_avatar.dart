import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Aura AI 심볼 아바타 — brandGradient 원 + sparkle 아이콘.
class AuraAvatar extends StatelessWidget {
  const AuraAvatar({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.55),
    );
  }
}

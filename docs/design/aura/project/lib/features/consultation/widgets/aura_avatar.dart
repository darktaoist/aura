// lib/features/consultation/widgets/aura_avatar.dart
//
// Aura 심볼 아바타 — brandGradient 로 채워진 원 + 내부 sparkle 아이콘.
// 채팅 AI 버블 왼쪽 / AppBar 좌측 등에 재사용.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuraAvatar extends StatelessWidget {
  const AuraAvatar({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

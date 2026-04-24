import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuraWordmark extends StatelessWidget {
  const AuraWordmark({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
      child: Text(
        'aura',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.0,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PalmCameraPage extends StatefulWidget {
  const PalmCameraPage({super.key});

  @override
  State<PalmCameraPage> createState() => _PalmCameraPageState();
}

class _PalmCameraPageState extends State<PalmCameraPage> {
  bool _isLeftHand = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('손금 보기'),
        actions: [
          // 좌/우 토글
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ToggleButtons(
              isSelected: [_isLeftHand, !_isLeftHand],
              onPressed: (i) => setState(() => _isLeftHand = i == 0),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: Colors.white54,
              selectedColor: Colors.white,
              fillColor: Colors.white24,
              constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
              children: const [
                Text('왼손', style: TextStyle(fontSize: 12)),
                Text('오른손', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.back_hand_outlined,
                size: 80, color: Colors.white30),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '손금 분석은 v1.1에서 지원됩니다',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Face 분석 완성 후 추가 예정',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

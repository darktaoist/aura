import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

enum _ScanState { idle, scanning, done }

/// 관상·손금 카메라 공통 — 하단 인식 상태 카드.
///
/// [progress] 0.0~1.0, [isStable] 안정화 완료 여부
/// [isFace]   true=관상(얼굴 가이드 문구), false=손금(손 가이드 문구)
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
    final state = isStable
        ? _ScanState.done
        : progress > 0
            ? _ScanState.scanning
            : _ScanState.idle;

    final String message;
    final IconData icon;
    final Color iconColor;

    switch (state) {
      case _ScanState.idle:
        message = isFace ? l10n.cameraGuideAlign : l10n.cameraGuideAlignHand;
        icon = isFace
            ? Icons.face_retouching_natural_outlined
            : Icons.back_hand_outlined;
        iconColor = Colors.white60;
      case _ScanState.scanning:
        message = l10n.cameraGuideScanning;
        icon = isFace ? Icons.face_retouching_natural : Icons.back_hand;
        iconColor = AppColors.seedDark;
      case _ScanState.done:
        message = l10n.cameraGuideDone;
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: state == _ScanState.done
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(icon,
                    key: ValueKey(state),
                    color: iconColor,
                    size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    message,
                    key: ValueKey(state),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (state == _ScanState.scanning) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.seedDark),
              ),
            ),
          ],
          if (state == _ScanState.done) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const LinearProgressIndicator(
                value: 1.0,
                minHeight: 8,
                backgroundColor: Color(0x26FFFFFF),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

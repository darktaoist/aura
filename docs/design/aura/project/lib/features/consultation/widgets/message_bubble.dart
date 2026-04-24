// lib/features/consultation/widgets/message_bubble.dart
//
// 채팅 메시지 버블. AI / 사용자 구분.
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • AI 버블: 좌측 Aura 아바타(24x24) + 꼬리(topLeft=4) + 카드 토큰 사용
// • 사용자 버블: brandGradient 유지 + subtle shadow 추가 + 꼬리(topRight=4)
// • 타임스탬프 / 복사 액션(롱프레스)는 기존 UX 보존
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart'; // 기존 (가정): role/text/createdAt
import 'aura_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final ChatMessage message;

  bool get _isAi => message.role == ChatRole.assistant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;

    final bubble = GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonCopied), // TODO: add key 'commonCopied'
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        decoration: _isAi
            ? BoxDecoration(
                color: aura.surfaceContainer,
                border: Border.all(color: aura.cardBorder, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: aura.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              )
            : BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.seed.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              message.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _isAi ? theme.colorScheme.onSurface : Colors.white,
                height: 1.6,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.Hm().format(message.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _isAi
                    ? aura.onSurfaceSubtle
                    : Colors.white.withOpacity(0.75),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          _isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: _isAi
          ? [const AuraAvatar(size: 24), const SizedBox(width: AppSpacing.sm), Flexible(child: bubble)]
          : [Flexible(child: bubble)],
    );
  }
}

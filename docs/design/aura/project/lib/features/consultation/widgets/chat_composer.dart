// lib/features/consultation/widgets/chat_composer.dart
//
// 채팅 입력 바 — 다행 입력 + 전송 버튼 + focused 상태 border.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;
    final canSend = _hasText && widget.enabled;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: aura.cardBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm,
        AppSpacing.md, AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: aura.surfaceContainer,
                border: Border.all(
                  color: _focus.hasFocus
                      ? theme.colorScheme.primary
                      : aura.cardBorder,
                  width: _focus.hasFocus ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 6),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintText: l10n.consultationComposerHint,
                  // TODO: add key 'consultationComposerHint'
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: canSend ? AppColors.brandGradient : null,
              color: canSend ? null : aura.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: canSend
                  ? [
                      BoxShadow(
                        color: AppColors.seed.withOpacity(0.35),
                        blurRadius: 12, offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: IconButton(
              onPressed: canSend ? _submit : null,
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: canSend ? Colors.white : aura.onSurfaceSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

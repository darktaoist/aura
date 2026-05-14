import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../../core/theme/app_colors.dart';

/// 항상 펼쳐진 리포트 섹션 카드. ExpansionTile 대체.
/// 스트리밍 중이면 border 가 accent 로 바뀌고 glow pulse 작동.
class ReadingSectionCard extends StatefulWidget {
  const ReadingSectionCard({
    super.key,
    required this.accent,
    required this.title,
    required this.body,
    required this.icon,
    this.isStreaming = false,
  });

  final Color accent;
  final String title;
  final String body;
  final IconData icon;
  final bool isStreaming;

  @override
  State<ReadingSectionCard> createState() => _ReadingSectionCardState();
}

class _ReadingSectionCardState extends State<ReadingSectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glowOpacity = widget.isStreaming
            ? 0.25 + 0.30 * _pulse.value
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bg2.withValues(alpha: 0.9),
                AppColors.bg1.withValues(alpha: 0.7),
              ],
            ),
            border: Border.all(
              color: widget.isStreaming ? aura.cardBorderAccent : aura.cardBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            boxShadow: [
              BoxShadow(
                color: aura.cardShadow,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
              if (widget.isStreaming)
                BoxShadow(
                  color: aura.glow.withValues(alpha: glowOpacity),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.sectionWash(widget.accent),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(widget.icon, size: 20, color: widget.accent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.accent,
                      ),
                    ),
                  ),
                  if (widget.isStreaming) _StreamingDot(color: widget.accent),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              MarkdownBody(
                data: widget.body,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                    letterSpacing: 0.05,
                  ),
                  h3: theme.textTheme.titleSmall?.copyWith(
                    color: widget.accent,
                    fontWeight: FontWeight.w600,
                    height: 2.0,
                  ),
                  strong: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ivory,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreamingDot extends StatefulWidget {
  const _StreamingDot({required this.color});
  final Color color;

  @override
  State<_StreamingDot> createState() => _StreamingDotState();
}

class _StreamingDotState extends State<_StreamingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.4 + 0.6 * _c.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

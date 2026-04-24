import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

Future<String?> showSubjectPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _SubjectPickerContent(),
  );
}

class _SubjectPickerContent extends StatefulWidget {
  const _SubjectPickerContent();

  @override
  State<_SubjectPickerContent> createState() => _SubjectPickerContentState();
}

class _SubjectPickerContentState extends State<_SubjectPickerContent> {
  int _selectedIndex = 0;
  bool _showCustom = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final l10n = AppLocalizations.of(context)!;
    final subjects = _quickSubjects(l10n);
    final name = _showCustom
        ? (_controller.text.trim().isEmpty ? subjects[0] : _controller.text.trim())
        : subjects[_selectedIndex];
    Navigator.pop(context, name);
  }

  List<String> _quickSubjects(AppLocalizations l10n) => [
        l10n.subjectMe,
        l10n.subjectSpouse,
        l10n.subjectFriend,
        l10n.subjectParents,
        l10n.subjectChild,
        l10n.subjectSibling,
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final subjects = _quickSubjects(l10n);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.subjectPickerTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.subjectPickerSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...subjects.asMap().entries.map((e) => _Chip(
                    label: e.value,
                    selected: !_showCustom && _selectedIndex == e.key,
                    onTap: () => setState(() {
                      _selectedIndex = e.key;
                      _showCustom = false;
                    }),
                  )),
              _Chip(
                label: l10n.subjectPickerCustom,
                selected: _showCustom,
                onTap: () => setState(() => _showCustom = true),
                icon: Icons.edit_outlined,
              ),
            ],
          ),
          if (_showCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: l10n.subjectPickerCustomHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _confirm(),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.subjectPickerConfirm,
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

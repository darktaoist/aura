import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

const _langs = [
  (code: 'ko', char: '韓', label: '한국어', sub: 'Korean'),
  (code: 'en', char: 'A',  label: 'English', sub: 'English'),
  (code: 'ja', char: '日', label: '日本語',  sub: 'Japanese'),
  (code: 'zh', char: '中', label: '中文',    sub: 'Chinese'),
];

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  String _selected = 'ko';

  Future<void> _confirm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _selected);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 52),
            // ── Header ──────────────────────────────────────────────────────
            _Ornament(),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.selectLanguageTitle,
              style: GoogleFonts.notoSerifKr(
                fontSize: 22, fontWeight: FontWeight.w400,
                color: AppColors.ivory, letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.selectLanguageSub,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10, letterSpacing: 3,
                color: AppColors.goldLight,
              ),
            ),

            const SizedBox(height: 36),

            // ── 2×2 Grid ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _langs.map((l) => _LangCard(
                    lang: l,
                    selected: _selected == l.code,
                    onTap: () => setState(() => _selected = l.code),
                  )).toList(),
                ),
              ),
            ),

            // ── Continue button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
              child: FilledButton(
                onPressed: _confirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: Text(
                  AppLocalizations.of(context)!.enterApp,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language card ─────────────────────────────────────────────────────────────

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  final ({String code, String char, String label, String sub}) lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: selected
                ? AppColors.goldLight.withValues(alpha: 0.8)
                : AppColors.hair2,
            width: 1,
          ),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x80251d12), Color(0x80120e08)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x08FFFFFF), Color(0x4D000000)],
                ),
          boxShadow: selected
              ? [BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 20, spreadRadius: 0,
                )]
              : null,
        ),
        child: Stack(
          children: [
            // corner brackets
            _CornerBrackets(active: selected),

            // content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 52,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.goldLight : AppColors.ivoryDim,
                      height: 1,
                    ),
                    child: Text(lang.char),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.label,
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: selected ? AppColors.ivory : AppColors.ivoryMid,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lang.sub.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, letterSpacing: 2,
                      color: selected ? AppColors.goldLight : AppColors.ivoryFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Corner bracket decoration ─────────────────────────────────────────────────

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(
        color: active ? AppColors.goldLight : AppColors.hair,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const m = 10.0;
    const l = 10.0;

    // top-left
    canvas.drawLine(Offset(m, m + l), Offset(m, m), paint);
    canvas.drawLine(Offset(m, m), Offset(m + l, m), paint);
    // top-right
    canvas.drawLine(Offset(size.width - m - l, m), Offset(size.width - m, m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + l), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width - m, size.height - m - l), Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m - l, size.height - m), paint);
    // bottom-left
    canvas.drawLine(Offset(m + l, size.height - m), Offset(m, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m, size.height - m - l), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

// ── Ornament divider ─────────────────────────────────────────────────────────

class _Ornament extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 14,
      child: CustomPaint(painter: _OrnamentPainter()),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.5)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final diamondPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(30, cy), linePaint);
    canvas.drawLine(Offset(50, cy), Offset(80, cy), linePaint);

    const cx = 40.0;
    const h = 5.0;
    final path = Path()
      ..moveTo(cx, cy - h)
      ..lineTo(cx + h / 1.4, cy)
      ..lineTo(cx, cy + h)
      ..lineTo(cx - h / 1.4, cy)
      ..close();
    canvas.drawPath(path, diamondPaint);
  }

  @override
  bool shouldRepaint(_OrnamentPainter _) => false;
}

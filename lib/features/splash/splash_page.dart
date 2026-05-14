import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../model_setup/model_config.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ringDraw;
  late final Animation<double> _fadeIn;
  late final Animation<double> _taglineIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _ringDraw = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    );
    _taglineIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );

    _ctrl.forward();
    _init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;
      final modelReady = await _ensureModelReady();
      if (!mounted) return;
      context.go(modelReady ? '/home' : '/model_setup');
    } catch (e) {
      if (mounted) context.go('/home');
    }
  }

  Future<bool> _ensureModelReady() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt('model_url_version') ?? 0;
    if (savedVersion < kModelUrlVersion) {
      debugPrint('[Splash] 모델 URL 버전 변경 ($savedVersion → $kModelUrlVersion) → 기존 파일 삭제');
      await deleteAllModelFiles();
      await prefs.setInt('model_url_version', kModelUrlVersion);
      return false;
    }

    final dirs = await buildScanDirs();
    for (final dir in dirs) {
      try {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final e in d.listSync(followLinks: false)) {
          if (e is File &&
              kModelExtensions.any(e.path.toLowerCase().endsWith)) {
            debugPrint('[Splash] 모델 파일 발견: ${e.path}');

            if (!await isValidModelContent(e)) {
              debugPrint('[Splash] 유효하지 않은 파일 삭제: ${e.path}');
              try { await e.delete(); } catch (_) {}
              continue;
            }

            try {
              final config = configForFile(e.path);
              await FlutterGemma.installModel(
                modelType: config.modelType,
                fileType: config.fileType,
              ).fromFile(e.path).install();
              debugPrint('[Splash] 모델 등록 완료 → ${e.path}');
              return true;
            } catch (regErr) {
              debugPrint('[Splash] 모델 재등록 실패: $regErr');
              return false;
            }
          }
        }
      } catch (_) {}
    }

    debugPrint('[Splash] 모델 파일 없음 → model_setup');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // constellation background
          ...List.generate(7, (i) => _StarParticle(seed: i * 37 + 11, screenSize: size)),

          // center composition
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // animated ring
                  AnimatedBuilder(
                    animation: _ringDraw,
                    builder: (_, __) => CustomPaint(
                      size: const Size(220, 220),
                      painter: _RingPainter(progress: _ringDraw.value),
                    ),
                  ),
                  // wordmark
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Aura',
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 52,
                            fontWeight: FontWeight.w300,
                            color: AppColors.ivory,
                            letterSpacing: 6,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _taglineIn,
                          child: Text(
                            '觀相 · 手相',
                            style: GoogleFonts.notoSerifKr(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.gold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 4;
    final innerR = outerR - 18;

    final goldPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final hairPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final nodePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    if (progress <= 0) return;

    // inner concentric ring — fades in first half
    final innerAlpha = (progress * 2.0).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      hairPaint..color = AppColors.gold.withValues(alpha: 0.15 * innerAlpha),
    );

    // outer arc sweeping from top
    final sweepAngle = -math.pi * 2 * progress;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      goldPaint,
    );

    // tick marks at 0°, 90°, 180°, 270°
    final tickFraction = (progress * 4).clamp(0.0, 1.0);
    final tickCount = (tickFraction * 4).floor();
    for (int i = 0; i < tickCount; i++) {
      final angle = -math.pi / 2 + (math.pi / 2) * i;
      final outer = Offset(
        cx + outerR * math.cos(angle),
        cy + outerR * math.sin(angle),
      );
      final inner = Offset(
        cx + (outerR - 8) * math.cos(angle),
        cy + (outerR - 8) * math.sin(angle),
      );
      canvas.drawLine(outer, inner, goldPaint..strokeWidth = 0.8);
    }

    // constellation nodes + lines (appear in second half)
    if (progress > 0.5) {
      final constellAlpha = ((progress - 0.5) * 2.0).clamp(0.0, 1.0);
      final nodes = _constellationNodes(cx, cy, outerR * 0.55);
      final linePaint = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.18 * constellAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      // edges between adjacent nodes
      final edges = [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4), (1, 3)];
      for (final (a, b) in edges) {
        canvas.drawLine(nodes[a], nodes[b], linePaint);
      }

      // node dots
      for (final node in nodes) {
        canvas.drawCircle(
          node,
          2.5,
          nodePaint..color = AppColors.gold.withValues(alpha: 0.5 * constellAlpha),
        );
      }
    }
  }

  List<Offset> _constellationNodes(double cx, double cy, double r) {
    // 5 nodes at fixed angles (pseudo-pentagon, offset)
    return [
      Offset(cx + r * math.cos(-math.pi / 2), cy + r * math.sin(-math.pi / 2)),
      Offset(cx + r * 0.9 * math.cos(-math.pi / 2 + math.pi * 0.4), cy + r * 0.9 * math.sin(-math.pi / 2 + math.pi * 0.4)),
      Offset(cx + r * 0.75 * math.cos(-math.pi / 2 + math.pi * 0.85), cy + r * 0.75 * math.sin(-math.pi / 2 + math.pi * 0.85)),
      Offset(cx + r * 0.75 * math.cos(-math.pi / 2 - math.pi * 0.85), cy + r * 0.75 * math.sin(-math.pi / 2 - math.pi * 0.85)),
      Offset(cx + r * 0.9 * math.cos(-math.pi / 2 - math.pi * 0.4), cy + r * 0.9 * math.sin(-math.pi / 2 - math.pi * 0.4)),
    ];
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Background star particle ──────────────────────────────────────────────────

class _StarParticle extends StatefulWidget {
  const _StarParticle({required this.seed, required this.screenSize});
  final int seed;
  final Size screenSize;

  @override
  State<_StarParticle> createState() => _StarParticleState();
}

class _StarParticleState extends State<_StarParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _x, _y, _size, _baseAlpha;

  @override
  void initState() {
    super.initState();
    final r = _pseudoRandom(widget.seed);
    _x = r[0];
    _y = r[1];
    _size = 1.0 + r[2] * 1.5;
    _baseAlpha = 0.15 + r[3] * 0.35;

    final period = Duration(milliseconds: (1800 + (r[4] * 1400).toInt()));
    _ctrl = AnimationController(vsync: this, duration: period)
      ..repeat(reverse: true);
  }

  List<double> _pseudoRandom(int seed) {
    // deterministic 5-value sequence from seed
    double h(int v) {
      final x = ((v ^ (v >> 16)) * 0x45d9f3b) & 0xFFFFFFFF;
      final y = ((x ^ (x >> 16)) * 0x45d9f3b) & 0xFFFFFFFF;
      return ((y ^ (y >> 16)) & 0xFFFFFF) / 0xFFFFFF;
    }
    return List.generate(5, (i) => h(seed + i * 1013));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x * widget.screenSize.width,
      top: _y * widget.screenSize.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ivory.withValues(
              alpha: _baseAlpha * (0.4 + 0.6 * _ctrl.value),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/subject_picker_sheet.dart';
import '../../../domain/entities/landmark_result.dart';
import '../../../models/consultation.dart';
import '../../../services/consultation_service.dart';
import '../../auth/auth_notifier.dart';
import 'face_result_notifier.dart';
import 'widgets/reading_hero.dart';
import 'widgets/reading_section_card.dart';

class FaceResultPage extends ConsumerStatefulWidget {
  const FaceResultPage({super.key, required this.result});

  final FaceLandmarkResult result;

  @override
  ConsumerState<FaceResultPage> createState() => _FaceResultPageState();
}

class _FaceResultPageState extends ConsumerState<FaceResultPage> {
  String _lastParsedText = '';
  Map<String, String> _cachedSections = {};
  bool _pendingSave = false;
  String? _savedReadingId;
  final _analyzedAt = DateTime.now();
  int _activeSection = 0;

  Map<String, String> _sections(String text) {
    if (text == _lastParsedText) return _cachedSections;
    _lastParsedText = text;
    _cachedSections = _parseSections(text);
    return _cachedSections;
  }

  @override
  void initState() {
    super.initState();
    _loadLocaleAndAnalyze();
  }

  Future<void> _loadLocaleAndAnalyze() async {
    final locale = ref.read(localeNotifierProvider).languageCode;
    debugPrint('[FaceResultPage] _loadLocaleAndAnalyze 시작, locale=$locale');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(faceResultNotifierProvider.notifier).analyze(
        result: widget.result, locale: locale,
      );
    });
  }

  Map<String, String> _parseSections(String text) {
    final result = <String, String>{};
    if (text.isEmpty) return result;
    final patterns = {
      'forehead': RegExp(r'^##\s*(이마|Forehead|額|额头)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
      'eyes': RegExp(r'^##\s*(눈|Eyes|目|眼睛)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
      'nose': RegExp(r'^##\s*(코|Nose|鼻|鼻子)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
      'mouth': RegExp(r'^##\s*(입|Mouth|口|嘴巴)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
      'chin': RegExp(r'^##\s*(턱|Chin|顎|下巴)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
      'overall': RegExp(r'^##\s*(종합|Overall|総合|综合)(.*?)(?=^##|$)',
          multiLine: true, dotAll: true, caseSensitive: false),
    };
    for (final e in patterns.entries) {
      final m = e.value.firstMatch(text);
      if (m != null) result[e.key] = m.group(2)?.trim() ?? '';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aura = context.auraColors;
    final notifierState = ref.watch(faceResultNotifierProvider);
    final isStreaming = notifierState.isStreaming;
    final fullText = notifierState.fullText;
    final error = notifierState.error;
    final isModelError = notifierState.isModelError;

    ref.listen(authNotifierProvider, (prev, next) {
      if (_pendingSave && prev?.isLoggedIn == false && next.isLoggedIn) {
        _pendingSave = false;
        _onSave(context);
      }
    });

    final kSections = [
      (key: 'forehead', label: l10n.sectionForehead,
          icon: Icons.person_outline,
          accent: aura.sectionAccents['forehead']!),
      (key: 'eyes',     label: l10n.sectionEyes,
          icon: Icons.visibility_outlined,
          accent: aura.sectionAccents['eyes']!),
      (key: 'nose',     label: l10n.sectionNose,
          icon: Icons.face_outlined,
          accent: aura.sectionAccents['nose']!),
      (key: 'mouth',    label: l10n.sectionMouth,
          icon: Icons.sentiment_satisfied_outlined,
          accent: aura.sectionAccents['mouth']!),
      (key: 'chin',     label: l10n.sectionChin,
          icon: Icons.face_retouching_natural,
          accent: aura.sectionAccents['chin']!),
      (key: 'overall',  label: l10n.sectionOverall,
          icon: Icons.auto_awesome_outlined,
          accent: aura.sectionAccents['overall']!),
    ];

    Widget body;
    if (error != null) {
      body = _buildError(context, l10n, error, isModelError: isModelError);
    } else if (isStreaming && fullText.isEmpty) {
      body = _buildLoading(context, l10n);
    } else {
      body = _buildContent(context, l10n, aura, fullText, isStreaming, kSections);
    }

    final showCta = !isStreaming && fullText.isNotEmpty && error == null;

    return PopScope(
      canPop: !isStreaming,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeave(context, l10n);
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg0,
        appBar: AppBar(
          backgroundColor: AppColors.bg0.withValues(alpha: 0.9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: isStreaming
                ? () async {
                    final leave = await _confirmLeave(context, l10n);
                    if (leave && context.mounted) context.pop();
                  }
                : () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.faceAnalysisResult,
                style: GoogleFonts.notoSerifKr(
                  fontSize: 15, color: AppColors.ivory, letterSpacing: 1,
                ),
              ),
              Text(
                '甲辰年 · ${DateTime.now().month}.${DateTime.now().day}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9, color: AppColors.ivoryFaint, letterSpacing: 2,
                ),
              ),
            ],
          ),
          actions: [
            // Confidence badge — 스트리밍 완료 후에만 표시
            if (!isStreaming && fullText.isNotEmpty && error == null)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5), width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.2),
                      AppColors.bg1.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.confidence,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8, letterSpacing: 1.5,
                        color: AppColors.goldLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(widget.result.score * 100).round()}',
                      style: GoogleFonts.notoSerifKr(
                        fontSize: 16, color: AppColors.ivory,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: body),
            if (showCta) _BottomCta(
              l10n: l10n,
              onSave: () => _onSave(context),
              onConsult: () => _onStartConsultation(context),
              onShare: _onShare,
            ),
          ],
        ),
      ),   // PopScope
    );
  }

  Future<bool> _confirmLeave(BuildContext context, AppLocalizations l10n) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.streamingBackTitle),
        content: Text(l10n.streamingBackBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.streamingBackLeave),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildLoading(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.brandGradient.createShader(b),
            child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.faceAnalyzing,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n,
      String errorMsg, {bool isModelError = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isModelError ? Icons.memory_outlined : Icons.error_outline,
              color: Colors.redAccent, size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isModelError ? l10n.aiModelError : l10n.analysisError,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(errorMsg,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            if (isModelError) ...[
              FilledButton.icon(
                onPressed: () => context.go('/model_setup'),
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.modelReinstall),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: () => context.pop(), child: Text(l10n.goBack)),
            ] else
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(faceResultNotifierProvider);
                  _loadLocaleAndAnalyze();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    AuraColors aura,
    String fullText,
    bool isStreaming,
    List<({String key, String label, IconData icon, Color accent})> kSections,
  ) {
    final sections = _sections(fullText);
    final hasSections = sections.values.any((v) => v.isNotEmpty);
    final availSections = kSections
        .where((s) => (sections[s.key] ?? '').isNotEmpty)
        .toList();

    final chips = hasSections
        ? availSections.map((s) => '#${s.label}').toList()
        : <String>[];
    final progress = (fullText.length / 1200).clamp(0.0, 1.0);

    // Han characters for section tabs
    const hanMap = {
      'overall':  '總',
      'forehead': '額',
      'eyes':     '眼',
      'nose':     '鼻',
      'mouth':    '口',
      'chin':     '頤',
    };

    return Column(
      children: [
        // Section tab bar
        if (hasSections && availSections.length > 1) ...[
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: availSections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (ctx, i) {
                final s = availSections[i];
                final active = i == _activeSection.clamp(0, availSections.length - 1);
                return GestureDetector(
                  onTap: () => setState(() => _activeSection = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: active
                            ? AppColors.gold.withValues(alpha: 0.7)
                            : AppColors.hair,
                        width: 1,
                      ),
                      gradient: active ? LinearGradient(colors: [
                        AppColors.gold.withValues(alpha: 0.2),
                        AppColors.bg1.withValues(alpha: 0.6),
                      ]) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hanMap[s.key] ?? '•',
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 14,
                            color: active ? AppColors.goldLight : AppColors.ivoryDim,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s.label,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12, letterSpacing: 0.3,
                            color: active ? AppColors.goldLight : AppColors.ivoryDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.hair, height: 1),
        ],

        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ReadingHero(
                analyzedAt: _analyzedAt,
                highlightChips: chips,
                isStreaming: isStreaming,
                progress: progress,
              ),
              const SizedBox(height: AppSpacing.md),

              if (isStreaming && !hasSections)
                ReadingSectionCard(
                  accent: aura.sectionAccents['overall']!,
                  title: l10n.analyzing,
                  body: fullText,
                  icon: Icons.auto_awesome,
                  isStreaming: true,
                )
              else if (!hasSections && fullText.isNotEmpty)
                ReadingSectionCard(
                  accent: aura.sectionAccents['overall']!,
                  title: l10n.faceAnalysisResult,
                  body: fullText,
                  icon: Icons.auto_awesome_outlined,
                  isStreaming: isStreaming,
                )
              else if (hasSections) ...[
                // Show active section (or all if only one)
                () {
                  final idx = _activeSection.clamp(0, availSections.length - 1);
                  final s = availSections[idx];
                  final text = sections[s.key] ?? '';
                  if (text.isEmpty) return const SizedBox.shrink();
                  return ReadingSectionCard(
                    accent: s.accent,
                    title: s.label,
                    body: text,
                    icon: s.icon,
                    isStreaming: s.key == 'overall' && isStreaming,
                  );
                }(),

                // Prev / Next navigation
                if (availSections.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _activeSection > 0
                              ? () => setState(() => _activeSection--)
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                _activeSection > 0
                                    ? availSections[_activeSection - 1].label
                                    : '',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10, letterSpacing: 1.5,
                                  color: AppColors.goldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(_activeSection + 1).toString().padLeft(2, '0')} / ${availSections.length.toString().padLeft(2, '0')}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10, letterSpacing: 1.5,
                            color: AppColors.ivoryFaint,
                          ),
                        ),
                        TextButton(
                          onPressed: _activeSection < availSections.length - 1
                              ? () => setState(() => _activeSection++)
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _activeSection < availSections.length - 1
                                    ? availSections[_activeSection + 1].label
                                    : '',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10, letterSpacing: 1.5,
                                  color: AppColors.goldLight,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.loginRequired),
          content: Text(l10n.loginRequiredContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.login)),
          ],
        ),
      );
      if (goLogin != true || !context.mounted) return;
      _pendingSave = true;
      context.push('/auth');
      return;
    }
    final subject = await showSubjectPickerSheet(context);
    if (subject == null || !context.mounted) return;
    await _doSave(subjectName: subject);
  }

  Future<void> _doSave({String subjectName = '나'}) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) return;
    final locale = ref.read(localeNotifierProvider).languageCode;
    try {
      final reading = await ref.read(faceResultNotifierProvider.notifier).saveReading(
        userId: authState.user!.id,
        landmarkResult: widget.result,
        modelUsed: 'E2B',
        locale: locale,
        subjectName: subjectName,
      );
      if (!mounted) return;
      final email = authState.user?.email ?? '';
      final displayName = email.contains('@') ? email.split('@').first : email;
      if (reading != null) setState(() => _savedReadingId = reading.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveSuccess(displayName))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.saveFailed}: $e')),
      );
    }
  }

  Future<void> _onStartConsultation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resultLoginToConsult)));
      context.push('/auth');
      return;
    }
    if (_savedReadingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resultSaveBeforeConsult)));
      return;
    }
    final locale = ref.read(localeNotifierProvider).languageCode;
    final fullText = ref.read(faceResultNotifierProvider).fullText;
    try {
      final consultation = await ref.read(consultationServiceProvider).createConsultation(
        userId: authState.user!.id,
        analysisType: AnalysisType.face,
        analysisId: _savedReadingId!,
        contextSummary: fullText.length > 600 ? '${fullText.substring(0, 600)}…' : fullText,
        contextFeatures: {
          'eyeSpan': widget.result.features.eyeSpan,
          'faceHeight': widget.result.features.faceHeight,
          'noseRatio': widget.result.features.noseRatio,
          'mouthWidth': widget.result.features.mouthWidth,
          'symmetry': widget.result.features.symmetry,
          'foreheadHeight': widget.result.features.foreheadHeight,
          'eyebrowDistance': widget.result.features.eyebrowDistance,
        },
        locale: locale,
        modelUsed: 'E2B',
      );
      if (!context.mounted) return;
      context.push('/consultation/${consultation.id}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.consultationCreateFailed}: $e')));
    }
  }

  void _onShare() {
    final l10n = AppLocalizations.of(context)!;
    final fullText = ref.read(faceResultNotifierProvider).fullText;
    if (fullText.isEmpty) return;

    final shareText = '${l10n.faceResultTitle}\n\n$fullText\n\n— Aura';
    SharePlus.instance.share(ShareParams(text: shareText));
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.l10n,
    required this.onSave,
    required this.onConsult,
    required this.onShare,
  });

  final AppLocalizations l10n;
  final VoidCallback onSave;
  final VoidCallback onConsult;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hair2, width: 1)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xFF0D0B14)],
        ),
      ),
      child: Row(
        children: [
          _GhostBtn(
            icon: Icons.bookmark_outline,
            label: l10n.save,
            onTap: onSave,
          ),
          const SizedBox(width: 8),
          _GhostBtn(
            icon: Icons.share_outlined,
            label: l10n.share,
            onTap: onShare,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onConsult,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE6C877), Color(0xFFC9A449)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.resultConsult,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13, letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1a1407),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('→',
                        style: TextStyle(color: Color(0xFF1a1407), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  const _GhostBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: AppColors.hair, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.goldLight),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 11, letterSpacing: 0.8,
                color: AppColors.ivoryMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

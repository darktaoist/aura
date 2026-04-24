import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/subject_picker_sheet.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/landmark_result.dart';
import '../../../models/consultation.dart';
import '../../../services/consultation_service.dart';
import '../../auth/auth_notifier.dart';
import 'face_result_notifier.dart';
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

    List<String> ragChunks = [];
    try {
      ragChunks = await ref.read(readingRepositoryProvider).ragSearch(
        type: 'face', queryEmbedding: _buildQueryEmbedding(),
      );
    } catch (e) {
      debugPrint('[FaceResultPage] RAG search failed (non-fatal): $e');
    }
    if (!mounted) return;

    ref.read(faceResultNotifierProvider.notifier).analyze(
      result: widget.result, locale: locale, ragChunks: ragChunks,
    );
  }

  List<double> _buildQueryEmbedding() {
    final f = widget.result.features;
    final base = [f.eyeSpan, f.faceHeight, f.noseRatio, f.mouthWidth, f.symmetry, f.foreheadHeight, f.eyebrowDistance];
    return List<double>.generate(768, (i) => i < base.length ? base[i] : 0.0);
  }

  Map<String, String> _parseSections(String text) {
    final Map<String, String> result = {};
    if (text.isEmpty) return result;

    final patterns = {
      'forehead': RegExp(r'^##\s*(이마|Forehead|額|额头)(.*?)(?=^##|$)',  multiLine: true, dotAll: true, caseSensitive: false),
      'eyes':     RegExp(r'^##\s*(눈|Eyes|目|眼睛)(.*?)(?=^##|$)',        multiLine: true, dotAll: true, caseSensitive: false),
      'nose':     RegExp(r'^##\s*(코|Nose|鼻|鼻子)(.*?)(?=^##|$)',        multiLine: true, dotAll: true, caseSensitive: false),
      'mouth':    RegExp(r'^##\s*(입|Mouth|口|嘴巴)(.*?)(?=^##|$)',       multiLine: true, dotAll: true, caseSensitive: false),
      'chin':     RegExp(r'^##\s*(턱|Chin|顎|下巴)(.*?)(?=^##|$)',        multiLine: true, dotAll: true, caseSensitive: false),
      'overall':  RegExp(r'^##\s*(종합|Overall|総合|综合)(.*?)(?=^##|$)',  multiLine: true, dotAll: true, caseSensitive: false),
    };

    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(text);
      if (match != null) result[entry.key] = match.group(2)?.trim() ?? '';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifierState = ref.watch(faceResultNotifierProvider);
    final isStreaming = notifierState.isStreaming;
    final fullText = notifierState.fullText;
    final error = notifierState.error;
    final isModelError = notifierState.isModelError;

    // 비로그인 → 로그인 완료 시 subject picker 띄우고 저장
    ref.listen(authNotifierProvider, (prev, next) {
      if (_pendingSave && prev?.isLoggedIn == false && next.isLoggedIn) {
        _pendingSave = false;
        _onSave(context);
      }
    });

    final kSections = [
      (key: 'forehead', label: l10n.sectionForehead, icon: Icons.person_outline),
      (key: 'eyes',     label: l10n.sectionEyes,     icon: Icons.visibility_outlined),
      (key: 'nose',     label: l10n.sectionNose,      icon: Icons.face_outlined),
      (key: 'mouth',    label: l10n.sectionMouth,     icon: Icons.sentiment_satisfied_outlined),
      (key: 'chin',     label: l10n.sectionChin,      icon: Icons.face_retouching_natural),
      (key: 'overall',  label: l10n.sectionOverall,   icon: Icons.auto_awesome_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.faceAnalysisResult),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: isStreaming ? null : () => _onSave(context),
            tooltip: l10n.save,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: isStreaming ? null : _onShare,
            tooltip: l10n.share,
          ),
        ],
      ),
      body: error != null
          ? _buildError(context, l10n, error, isModelError: isModelError)
          : isStreaming && fullText.isEmpty
              ? _buildLoading(context, l10n)
              : _buildContent(context, l10n, fullText, isStreaming, kSections),
    );
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
          Text(l10n.faceAnalyzing, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n, String errorMsg, {bool isModelError = false}) {
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
            Text(errorMsg, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
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
    String fullText,
    bool isStreaming,
    List<({String key, String label, IconData icon})> kSections,
  ) {
    final sections = _sections(fullText);
    final hasSections = sections.values.any((v) => v.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        if (isStreaming && !hasSections)
          ReadingSectionCard(
            title: l10n.analyzing,
            content: fullText,
            icon: Icons.auto_awesome,
            isStreaming: true,
          )
        else if (!hasSections && fullText.isNotEmpty)
          ReadingSectionCard(
            title: l10n.faceAnalysisResult,
            content: fullText,
            icon: Icons.auto_awesome_outlined,
            isStreaming: isStreaming,
          )
        else
          ...kSections.map((s) {
            final text = sections[s.key] ?? '';
            if (text.isEmpty) return const SizedBox.shrink();
            return ReadingSectionCard(
              title: s.label,
              content: text,
              icon: s.icon,
              isStreaming: s.key == 'overall' && isStreaming,
            );
          }),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isStreaming ? null : () => _onSave(context),
                  icon: const Icon(Icons.bookmark_outline),
                  label: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: isStreaming ? null : () => _onStartConsultation(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(l10n.resultStartConsultation),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
      SnackBar(
        content: Text(reading != null ? l10n.saveSuccess(displayName) : l10n.saveFailed),
      ),
    );
  }

  Future<void> _onStartConsultation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resultLoginToConsult)),
      );
      context.push('/auth');
      return;
    }
    if (_savedReadingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resultSaveBeforeConsult)),
      );
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
        SnackBar(content: Text('${l10n.consultationCreateFailed}: $e')),
      );
    }
  }

  void _onShare() {
    // TODO Phase 7: 공유 기능
  }
}

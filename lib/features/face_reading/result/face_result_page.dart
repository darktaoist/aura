import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/landmark_result.dart';
import 'face_result_notifier.dart';
import 'widgets/reading_section_card.dart';

const _kSections = [
  (key: 'forehead', label: '이마',  icon: Icons.person_outline),
  (key: 'eyes',     label: '눈',    icon: Icons.visibility_outlined),
  (key: 'nose',     label: '코',    icon: Icons.face_outlined),
  (key: 'mouth',    label: '입',    icon: Icons.sentiment_satisfied_outlined),
  (key: 'chin',     label: '턱',    icon: Icons.face_retouching_natural),
  (key: 'overall',  label: '종합',  icon: Icons.auto_awesome_outlined),
];

class FaceResultPage extends ConsumerStatefulWidget {
  const FaceResultPage({super.key, required this.result});

  final FaceLandmarkResult result;

  @override
  ConsumerState<FaceResultPage> createState() => _FaceResultPageState();
}

class _FaceResultPageState extends ConsumerState<FaceResultPage> {
  // _sections 메모이제이션
  String _lastParsedText = '';
  Map<String, String> _cachedSections = {};

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
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale') ?? 'ko';

    if (!mounted) return;

    // RAG 검색 (실패 시 빈 목록으로 폴백 — 분석 자체는 항상 진행)
    List<String> ragChunks = [];
    try {
      ragChunks = await ref.read(readingRepositoryProvider).ragSearch(
        type: 'face',
        queryEmbedding: _buildQueryEmbedding(),
      );
    } catch (e) {
      debugPrint('[FaceResultPage] RAG search failed (non-fatal): $e');
    }

    if (!mounted) return;

    ref.read(faceResultNotifierProvider.notifier).analyze(
          result: widget.result,
          locale: locale,
          ragChunks: ragChunks,
        );
  }

  /// 랜드마크 기반 간단 쿼리 임베딩 (placeholder — v1.1에서 MiniLM으로 교체)
  /// 현재는 특이점 값들의 정규화된 배열을 임베딩 대신 전송
  List<double> _buildQueryEmbedding() {
    final f = widget.result.features;
    // 768차원 zero-padded (실제 임베딩 미구현 단계)
    final base = [
      f.eyeSpan, f.faceHeight, f.noseRatio,
      f.mouthWidth, f.symmetry, f.foreheadHeight, f.eyebrowDistance,
    ];
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
      if (match != null) {
        result[entry.key] = match.group(2)?.trim() ?? '';
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(faceResultNotifierProvider);
    final isStreaming = notifierState.isStreaming;
    final fullText = notifierState.fullText;
    final error = notifierState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('관상 분석 결과'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: isStreaming ? null : () => _onSave(context),
            tooltip: '저장',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: isStreaming ? null : _onShare,
            tooltip: '공유',
          ),
        ],
      ),
      body: error != null
          ? _buildError(error)
          : isStreaming && fullText.isEmpty
              ? _buildLoading()
              : _buildContent(context, fullText, isStreaming),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.brandGradient.createShader(b),
            child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('관상 분석 중...', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildError(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text('분석 중 오류가 발생했습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text(errorMsg,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(faceResultNotifierProvider);
                _loadLocaleAndAnalyze();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String fullText, bool isStreaming) {
    final sections = _sections(fullText);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        if (sections.isEmpty && isStreaming)
          ReadingSectionCard(
            title: '분석 중...',
            content: fullText,
            icon: Icons.auto_awesome,
            isStreaming: true,
          )
        else
          ..._kSections.map((s) {
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
                  label: const Text('다시 보기'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isStreaming ? null : () => _onSave(context),
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  void _onSave(BuildContext context) {
    context.push('/auth?from=save');
  }

  void _onShare() {
    // TODO Phase 7: 공유 기능
  }
}

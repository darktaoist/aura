import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/subject_picker_sheet.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/landmark_result.dart';
import '../../../models/consultation.dart';
import '../../../services/consultation_service.dart';
import '../../auth/auth_notifier.dart';
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
  // 비로그인 상태에서 저장 요청 → 로그인 후 자동 저장 플래그
  bool _pendingSave = false;
  // 저장 완료 후 상담 가능 상태
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
    final isModelError = notifierState.isModelError;

    // 비로그인 → 로그인 완료 시 subject picker 띄우고 저장
    ref.listen(authNotifierProvider, (prev, next) {
      if (_pendingSave && prev?.isLoggedIn == false && next.isLoggedIn) {
        _pendingSave = false;
        _onSave(context);
      }
    });

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
          ? _buildError(error, isModelError: isModelError)
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

  Widget _buildError(String errorMsg, {bool isModelError = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isModelError ? Icons.memory_outlined : Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isModelError ? 'AI 모델 오류' : '분석 중 오류가 발생했습니다',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMsg,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isModelError) ...[
              FilledButton.icon(
                onPressed: () => context.go('/model_setup'),
                icon: const Icon(Icons.download_outlined),
                label: const Text('모델 재설치'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ] else
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
    final hasSections = sections.values.any((v) => v.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        if (isStreaming && !hasSections)
          // 스트리밍 중 섹션 파싱 전: 원문 표시
          ReadingSectionCard(
            title: '분석 중...',
            content: fullText,
            icon: Icons.auto_awesome,
            isStreaming: true,
          )
        else if (!hasSections && fullText.isNotEmpty)
          // 섹션 파싱 실패: 전체 텍스트 단일 카드로 표시
          ReadingSectionCard(
            title: '분석 결과',
            content: fullText,
            icon: Icons.auto_awesome_outlined,
            isStreaming: isStreaming,
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
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: isStreaming ? null : () => _onStartConsultation(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('상담하기'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final authState = ref.read(authNotifierProvider);

    if (!authState.isLoggedIn) {
      // 비로그인: 저장 대기 플래그 설정 후 로그인으로 이동
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('로그인 필요'),
          content: const Text('저장하려면 로그인이 필요합니다.\n로그인 후 자동으로 저장됩니다.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그인')),
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
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale') ?? 'ko';

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

    if (reading != null) {
      setState(() => _savedReadingId = reading.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reading != null
            ? '$displayName님의 결과가 저장되었습니다'
            : '저장에 실패했습니다. 다시 시도해주세요.'),
      ),
    );
  }

  Future<void> _onStartConsultation(BuildContext context) async {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상담하려면 로그인이 필요합니다')),
      );
      context.push('/auth');
      return;
    }
    if (_savedReadingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 저장해주세요')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale') ?? 'ko';
    final fullText = ref.read(faceResultNotifierProvider).fullText;

    try {
      final consultation = await ref.read(consultationServiceProvider).createConsultation(
            userId: authState.user!.id,
            analysisType: AnalysisType.face,
            analysisId: _savedReadingId!,
            contextSummary: fullText.length > 600
                ? '${fullText.substring(0, 600)}…'
                : fullText,
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
        SnackBar(content: Text('상담 생성 실패: $e')),
      );
    }
  }

  void _onShare() {
    // TODO Phase 7: 공유 기능
  }
}

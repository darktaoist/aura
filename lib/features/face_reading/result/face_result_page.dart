import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/gemma/gemma_service.dart';
import '../../../domain/entities/landmark_result.dart';
import 'widgets/reading_section_card.dart';

/// 결과화면용 섹션 정의
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
  final GemmaService _gemma = GemmaService._getInstance();

  String _fullText = '';
  bool _isStreaming = true;
  String _locale = 'ko';

  /// 섹션별 파싱된 텍스트
  Map<String, String> get _sections => _parseSections(_fullText);

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    final buffer = StringBuffer();
    await for (final token in _gemma.analyzeLongForm(
      result: widget.result,
      locale: _locale,
    )) {
      buffer.write(token);
      if (mounted) setState(() => _fullText = buffer.toString());
    }
    if (mounted) setState(() => _isStreaming = false);
  }

  // ## 섹션명 패턴으로 파싱
  Map<String, String> _parseSections(String text) {
    final Map<String, String> result = {};
    if (text.isEmpty) return result;

    final patterns = {
      'forehead': RegExp(r'##\s*(이마|Forehead|額|额头)(.*?)(?=##|$)', dotAll: true, caseSensitive: false),
      'eyes':     RegExp(r'##\s*(눈|Eyes|目|眼睛)(.*?)(?=##|$)',      dotAll: true, caseSensitive: false),
      'nose':     RegExp(r'##\s*(코|Nose|鼻|鼻子)(.*?)(?=##|$)',      dotAll: true, caseSensitive: false),
      'mouth':    RegExp(r'##\s*(입|Mouth|口|嘴巴)(.*?)(?=##|$)',     dotAll: true, caseSensitive: false),
      'chin':     RegExp(r'##\s*(턱|Chin|顎|下巴)(.*?)(?=##|$)',     dotAll: true, caseSensitive: false),
      'overall':  RegExp(r'##\s*(종합|Overall|総合|综合)(.*?)(?=##|$)', dotAll: true, caseSensitive: false),
    };

    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(text);
      if (match != null) {
        result[entry.key] = match.group(2)?.trim() ?? '';
      }
    }

    // 섹션 파싱 전 스트리밍 중이면 전체 텍스트를 overall에
    if (result.isEmpty && _isStreaming) {
      result['overall'] = text;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관상 분석 결과'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () => _onSave(context),
            tooltip: '저장',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _isStreaming ? null : _onShare,
            tooltip: '공유',
          ),
        ],
      ),
      body: _isStreaming && _fullText.isEmpty
          ? _buildLoading()
          : _buildContent(context),
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
          Text(
            '관상 분석 중...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final sections = _sections;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        // 스트리밍 중 섹션 파싱 전: 전체 텍스트 카드
        if (sections.isEmpty && _isStreaming)
          ReadingSectionCard(
            title: '분석 중...',
            content: _fullText,
            icon: Icons.auto_awesome,
            isStreaming: true,
          )
        else
          ..._kSections.map((s) {
            final text = sections[s.key] ?? '';
            if (text.isEmpty) return const SizedBox.shrink();
            final isLastSection =
                s.key == 'overall' && _isStreaming;
            return ReadingSectionCard(
              title: s.label,
              content: text,
              icon: s.icon,
              isStreaming: isLastSection,
            );
          }),
        const SizedBox(height: AppSpacing.xl),
        // 하단 액션 버튼
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
                  onPressed: _isStreaming ? null : () => _onSave(context),
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
    // TODO Phase 7: 로그인 확인 후 Supabase 저장
    context.push('/auth?from=save');
  }

  void _onShare() {
    // TODO Phase 7: 공유 기능
  }
}

// GemmaService 싱글톤 임시 접근자 (Phase 7에서 Riverpod provider로 교체)
extension on GemmaService {
  static GemmaService? _instance;
  static GemmaService _getInstance() {
    // 실제로는 riverpod provider에서 관리
    return GemmaService._();
  }
}

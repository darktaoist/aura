import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../data/supabase/reading_repository.dart';
import '../../domain/entities/reading.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';
import '../auth/auth_notifier.dart';
import 'widgets/analysis_pick_card.dart';

class AnalysisPickerScreen extends ConsumerStatefulWidget {
  const AnalysisPickerScreen({super.key});

  @override
  ConsumerState<AnalysisPickerScreen> createState() =>
      _AnalysisPickerScreenState();
}

class _AnalysisPickerScreenState extends ConsumerState<AnalysisPickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final Future<List<Reading>> _future;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final userId = ref.read(authNotifierProvider).user?.id ?? '';
    _future = ref.read(readingRepositoryProvider).getHistory(userId);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _startConsultation(Reading reading) async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final authState = ref.read(authNotifierProvider);
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('locale') ?? 'ko';

      final consultation = await ref.read(consultationServiceProvider).createConsultation(
            userId: authState.user!.id,
            analysisType:
                reading.type == ReadingType.face ? AnalysisType.face : AnalysisType.palm,
            analysisId: reading.id,
            contextSummary: _buildSummary(reading.resultText),
            contextFeatures: reading.features ?? {},
            locale: locale,
            modelUsed: reading.modelUsed ?? 'E2B',
          );

      if (!mounted) return;
      context.pushReplacement('/consultation/${consultation.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상담 생성 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  String _buildSummary(String resultText) {
    if (resultText.length <= 600) return resultText;
    return '${resultText.substring(0, 600)}…';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 선택'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: '관상'),
            Tab(text: '손금'),
          ],
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Reading>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('오류: ${snapshot.error}'));
              }

              final all = snapshot.data ?? [];
              final faceReadings =
                  all.where((r) => r.type == ReadingType.face).toList();
              final palmReadings =
                  all.where((r) => r.type == ReadingType.palm).toList();

              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _ReadingList(
                    readings: faceReadings,
                    emptyIcon: Icons.face_retouching_natural,
                    emptyLabel: '저장된 관상 분석이 없습니다',
                    onStartCamera: () => context.push('/face/camera'),
                    onPick: _startConsultation,
                  ),
                  _ReadingList(
                    readings: palmReadings,
                    emptyIcon: Icons.back_hand_outlined,
                    emptyLabel: '저장된 손금 분석이 없습니다',
                    onStartCamera: () => context.push('/palm/camera'),
                    onPick: _startConsultation,
                  ),
                ],
              );
            },
          ),
          if (_isCreating)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ReadingList extends StatelessWidget {
  const _ReadingList({
    required this.readings,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.onStartCamera,
    required this.onPick,
  });

  final List<Reading> readings;
  final IconData emptyIcon;
  final String emptyLabel;
  final VoidCallback onStartCamera;
  final void Function(Reading) onPick;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              emptyLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onStartCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('분석 시작하기'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: readings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => AnalysisPickCard(
        reading: readings[i],
        onTap: () => onPick(readings[i]),
      ),
    );
  }
}

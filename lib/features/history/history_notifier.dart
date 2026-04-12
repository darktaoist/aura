import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/supabase/reading_repository.dart';
import '../../domain/entities/reading.dart';
import '../auth/auth_notifier.dart';

part 'history_notifier.g.dart';

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<Reading>> build() async {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null) return [];

    return ref.read(readingRepositoryProvider).getHistory(user.id);
  }

  Future<void> deleteReading(String readingId) async {
    await ref.read(readingRepositoryProvider).deleteReading(readingId);
    ref.invalidateSelf();
  }
}

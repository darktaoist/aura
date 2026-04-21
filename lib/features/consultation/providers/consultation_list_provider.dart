import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/consultation.dart';
import '../../../services/consultation_service.dart';
import '../../auth/auth_notifier.dart';

part 'consultation_list_provider.g.dart';

@riverpod
Future<List<Consultation>> consultationList(Ref ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (!authState.isLoggedIn) return [];

  return ref
      .read(consultationServiceProvider)
      .getConsultations(authState.user!.id);
}

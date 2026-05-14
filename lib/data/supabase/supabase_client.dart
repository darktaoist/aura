import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    throw StateError('Supabase가 초기화되지 않았습니다. --dart-define으로 SUPABASE_URL/ANON_KEY를 전달하세요.');
  }
}

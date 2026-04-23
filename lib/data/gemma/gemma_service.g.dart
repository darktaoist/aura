// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gemmaServiceHash() => r'd9057f3fcf5c2728d577eb6b85fc870f66bc9782';

/// 앱 생애 동안 단 한 번만 로드되는 Gemma 모델 서비스.
/// keepAlive=true 로 provider가 dispose 되지 않고 모델을 보존한다.
///
/// Copied from [gemmaService].
@ProviderFor(gemmaService)
final gemmaServiceProvider = FutureProvider<GemmaService>.internal(
  gemmaService,
  name: r'gemmaServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gemmaServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GemmaServiceRef = FutureProviderRef<GemmaService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

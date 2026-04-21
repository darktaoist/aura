// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$consultationChatHash() => r'56e28370f98fe3d7f66684584c7d7236ebd07da4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ConsultationChat
    extends BuildlessAutoDisposeNotifier<ConsultationChatState> {
  late final String consultationId;

  ConsultationChatState build(String consultationId);
}

/// See also [ConsultationChat].
@ProviderFor(ConsultationChat)
const consultationChatProvider = ConsultationChatFamily();

/// See also [ConsultationChat].
class ConsultationChatFamily extends Family<ConsultationChatState> {
  /// See also [ConsultationChat].
  const ConsultationChatFamily();

  /// See also [ConsultationChat].
  ConsultationChatProvider call(String consultationId) {
    return ConsultationChatProvider(consultationId);
  }

  @override
  ConsultationChatProvider getProviderOverride(
    covariant ConsultationChatProvider provider,
  ) {
    return call(provider.consultationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'consultationChatProvider';
}

/// See also [ConsultationChat].
class ConsultationChatProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ConsultationChat,
          ConsultationChatState
        > {
  /// See also [ConsultationChat].
  ConsultationChatProvider(String consultationId)
    : this._internal(
        () => ConsultationChat()..consultationId = consultationId,
        from: consultationChatProvider,
        name: r'consultationChatProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$consultationChatHash,
        dependencies: ConsultationChatFamily._dependencies,
        allTransitiveDependencies:
            ConsultationChatFamily._allTransitiveDependencies,
        consultationId: consultationId,
      );

  ConsultationChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.consultationId,
  }) : super.internal();

  final String consultationId;

  @override
  ConsultationChatState runNotifierBuild(covariant ConsultationChat notifier) {
    return notifier.build(consultationId);
  }

  @override
  Override overrideWith(ConsultationChat Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConsultationChatProvider._internal(
        () => create()..consultationId = consultationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        consultationId: consultationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ConsultationChat, ConsultationChatState>
  createElement() {
    return _ConsultationChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConsultationChatProvider &&
        other.consultationId == consultationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, consultationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConsultationChatRef
    on AutoDisposeNotifierProviderRef<ConsultationChatState> {
  /// The parameter `consultationId` of this provider.
  String get consultationId;
}

class _ConsultationChatProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ConsultationChat,
          ConsultationChatState
        >
    with ConsultationChatRef {
  _ConsultationChatProviderElement(super.provider);

  @override
  String get consultationId =>
      (origin as ConsultationChatProvider).consultationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

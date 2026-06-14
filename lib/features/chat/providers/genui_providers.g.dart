// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$widgetStateNotifierHash() =>
    r'9075e3889939e86df69e035fea7d782b03c1ee5f';

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

abstract class _$WidgetStateNotifier
    extends BuildlessAutoDisposeNotifier<Map<String, dynamic>> {
  late final String widgetId;

  Map<String, dynamic> build(String widgetId);
}

/// See also [WidgetStateNotifier].
@ProviderFor(WidgetStateNotifier)
const widgetStateNotifierProvider = WidgetStateNotifierFamily();

/// See also [WidgetStateNotifier].
class WidgetStateNotifierFamily extends Family<Map<String, dynamic>> {
  /// See also [WidgetStateNotifier].
  const WidgetStateNotifierFamily();

  /// See also [WidgetStateNotifier].
  WidgetStateNotifierProvider call(String widgetId) {
    return WidgetStateNotifierProvider(widgetId);
  }

  @override
  WidgetStateNotifierProvider getProviderOverride(
    covariant WidgetStateNotifierProvider provider,
  ) {
    return call(provider.widgetId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'widgetStateNotifierProvider';
}

/// See also [WidgetStateNotifier].
class WidgetStateNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          WidgetStateNotifier,
          Map<String, dynamic>
        > {
  /// See also [WidgetStateNotifier].
  WidgetStateNotifierProvider(String widgetId)
    : this._internal(
        () => WidgetStateNotifier()..widgetId = widgetId,
        from: widgetStateNotifierProvider,
        name: r'widgetStateNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$widgetStateNotifierHash,
        dependencies: WidgetStateNotifierFamily._dependencies,
        allTransitiveDependencies:
            WidgetStateNotifierFamily._allTransitiveDependencies,
        widgetId: widgetId,
      );

  WidgetStateNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.widgetId,
  }) : super.internal();

  final String widgetId;

  @override
  Map<String, dynamic> runNotifierBuild(
    covariant WidgetStateNotifier notifier,
  ) {
    return notifier.build(widgetId);
  }

  @override
  Override overrideWith(WidgetStateNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: WidgetStateNotifierProvider._internal(
        () => create()..widgetId = widgetId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        widgetId: widgetId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<WidgetStateNotifier, Map<String, dynamic>>
  createElement() {
    return _WidgetStateNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WidgetStateNotifierProvider && other.widgetId == widgetId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, widgetId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WidgetStateNotifierRef
    on AutoDisposeNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `widgetId` of this provider.
  String get widgetId;
}

class _WidgetStateNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          WidgetStateNotifier,
          Map<String, dynamic>
        >
    with WidgetStateNotifierRef {
  _WidgetStateNotifierProviderElement(super.provider);

  @override
  String get widgetId => (origin as WidgetStateNotifierProvider).widgetId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

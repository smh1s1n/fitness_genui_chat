import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'genui_providers.g.dart';

@riverpod
class WidgetStateNotifier extends _$WidgetStateNotifier {
  @override
  Map<String, dynamic> build(String widgetId) {
    return const {};
  }

  /// Initialize the state with the initial payload if it's currently empty
  void initialize(Map<String, dynamic> initialData) {
    if (state.isEmpty) {
      state = Map<String, dynamic>.from(initialData);
    }
  }

  /// Perform a state mutation and notify consumers
  void updateState(Map<String, dynamic> Function(Map<String, dynamic> current) updater) {
    state = Map<String, dynamic>.from(updater(state));
  }
}

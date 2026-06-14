import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  static const _apiKeyKey = 'gemini_api_key';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> setApiKey(String? key) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      if (key == null || key.trim().isEmpty) {
        await prefs.remove(_apiKeyKey);
        return null;
      } else {
        final cleanKey = key.trim();
        await prefs.setString(_apiKeyKey, cleanKey);
        return cleanKey;
      }
    });
  }
}

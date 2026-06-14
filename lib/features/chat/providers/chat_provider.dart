import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/gemini_client.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/chat_message.dart';
import '../models/genui_widget_data.dart';

part 'chat_provider.g.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    required this.messages,
    required this.isLoading,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  static const _uuid = Uuid();

  @override
  ChatState build() {
    // Return initial greeting message
    final welcomeMessage = ChatMessage.model(
      id: _uuid.v4(),
      text: "Hello! I'm Aegis, your AI Fitness Coach (developed by Syed Mahamudul Hasan). I can help you program custom workouts, track macros, set timers, and analyze your metrics. How can I help you smash your fitness goals today?",
    );

    return ChatState(
      messages: [welcomeMessage],
      isLoading: false,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMessage = ChatMessage.user(
      id: _uuid.v4(),
      text: text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final apiKey = ref.read(settingsNotifierProvider).value;
      Map<String, dynamic> aiResponse;

      if (apiKey != null && apiKey.isNotEmpty) {
        // Use live Gemini API client
        final client = GeminiClient(apiKey: apiKey);
        aiResponse = await client.generateResponse(state.messages, text);
      } else {
        // Fallback to high-fidelity local simulation for development
        // Wait 1.5 seconds to simulate API delay
        await Future.delayed(const Duration(milliseconds: 1200));
        aiResponse = GeminiClient.mockResponse(text);
      }

      final textResponse = aiResponse['text'] as String? ?? '';
      final rawWidget = aiResponse['widget'] as Map<String, dynamic>?;

      GenUIWidgetData? widgetData;
      if (rawWidget != null && rawWidget['type'] != null) {
        widgetData = GenUIWidgetData.fromJson(
          _uuid.v4(),
          rawWidget,
        );
      }

      final coachMessage = ChatMessage.model(
        id: _uuid.v4(),
        text: textResponse,
        widgetData: widgetData,
      );

      state = state.copyWith(
        messages: [...state.messages, coachMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage.model(
        id: _uuid.v4(),
        text: "Sorry, I encountered an error. Please verify your internet connection or check your Gemini API key in settings. Details: $e",
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = build();
  }
}

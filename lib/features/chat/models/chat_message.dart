import 'genui_widget_data.dart';

enum MessageRole { user, model }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final GenUIWidgetData? widgetData;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.widgetData,
    required this.timestamp,
  });

  factory ChatMessage.user({required String id, required String text}) {
    return ChatMessage(
      id: id,
      role: MessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.model({
    required String id,
    required String text,
    GenUIWidgetData? widgetData,
  }) {
    return ChatMessage(
      id: id,
      role: MessageRole.model,
      text: text,
      widgetData: widgetData,
      timestamp: DateTime.now(),
    );
  }
}

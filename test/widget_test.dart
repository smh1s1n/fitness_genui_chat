import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_genui_chat/main.dart';
import 'package:fitness_genui_chat/features/chat/views/chat_screen.dart';

void main() {
  testWidgets('Chat screen renders initial greeting', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AegisApp(),
      ),
    );

    // Allow widgets to settle
    await tester.pumpAndSettle();

    // Verify that the chat screen is loaded
    expect(find.byType(ChatScreen), findsOneWidget);
    
    // Verify that the initial greeting message from the coach is displayed
    expect(find.textContaining('AI Fitness Coach'), findsOneWidget);
  });
}

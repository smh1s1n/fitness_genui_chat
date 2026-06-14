import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/views/chat_screen.dart';

void main() {
  // Ensure Flutter framework is fully initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: AegisApp(),
    ),
  );
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Fitness Coach',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Defaulting to the premium dark aesthetic
      darkTheme: AppTheme.darkTheme,
      home: const ChatScreen(),
    );
  }
}

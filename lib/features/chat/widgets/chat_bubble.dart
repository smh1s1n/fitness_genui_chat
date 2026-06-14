import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import 'genui_renderer.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    
    // Bubble decorations
    final bubbleColor = isUser ? AppColors.primaryStart : AppColors.surfaceCard;
    final textColor = isUser ? Colors.white : AppColors.textPrimary;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Role name indicator (Coach / You)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 6, right: 6),
            child: Text(
              isUser ? 'You' : 'Aegis (Coach)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ),

          // Message bubble row (using ConstrainedBox to restrict size on web/desktop)
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                // Tiny round avatar for coach
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Text message card
                      if (message.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: borderRadius,
                            border: Border.all(
                              color: isUser ? Colors.transparent : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),
                        ),

                      // Optional GenUI Widget attached
                      if (message.widgetData != null) ...[
                        const SizedBox(height: 10),
                        GenUIRenderer(widgetData: message.widgetData!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

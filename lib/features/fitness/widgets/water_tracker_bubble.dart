import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class WaterTrackerBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const WaterTrackerBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<WaterTrackerBubble> createState() => _WaterTrackerBubbleState();
}

class _WaterTrackerBubbleState extends ConsumerState<WaterTrackerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Safely initialize the provider's state with the initial AI response data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize(widget.initialData);
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widgetStateNotifierProvider(widget.widgetId));
    if (state.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondaryStart),
        ),
      );
    }

    final target = (state['targetDailyMl'] as num?)?.toDouble() ?? 2500.0;
    final current = (state['currentMl'] as num?)?.toDouble() ?? 0.0;
    final percentage = (current / target).clamp(0.0, 1.0);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Hydration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Goal: ${target.toInt()} ml',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryStart.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: AppColors.secondaryStart,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.secondaryStart,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom animated wave visualization
          Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(
                      waveAnimationValue: _waveController.value,
                      fillPercentage: percentage,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${current.toInt()}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'ml logged',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Log quick buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _QuickLogButton(
                    label: '+250ml',
                    onTap: () => _addWater(250),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickLogButton(
                    label: '+500ml',
                    onTap: () => _addWater(500),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickLogButton(
                    label: '+1L',
                    onTap: () => _addWater(1000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addWater(double ml) {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final currentMl = (current['currentMl'] as num?)?.toDouble() ?? 0.0;
        return {...current, 'currentMl': currentMl + ml};
      },
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickLogButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveAnimationValue;
  final double fillPercentage;

  WavePainter({required this.waveAnimationValue, required this.fillPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    // Background deep color
    final bgPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (fillPercentage <= 0) return;

    final baseHeight = size.height * (1.0 - fillPercentage);

    final path1 = Path();
    final path2 = Path();

    // Wave parameters
    const waveAmplitude1 = 6.0;
    const waveAmplitude2 = 4.0;
    final waveLength = size.width;

    path1.moveTo(0, size.height);
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      // Wave 1
      final angle1 = (x / waveLength) * 2 * pi + (waveAnimationValue * 2 * pi);
      final y1 = baseHeight + sin(angle1) * waveAmplitude1;
      path1.lineTo(x, y1.clamp(0.0, size.height));

      // Wave 2 (offset phase & speed)
      final angle2 =
          (x / waveLength) * 2 * pi -
          (waveAnimationValue * 2 * pi * 1.5) +
          pi / 4;
      final y2 = baseHeight + cos(angle2) * waveAmplitude2;
      path2.lineTo(x, y2.clamp(0.0, size.height));
    }

    path1.lineTo(size.width, size.height);
    path1.close();
    path2.lineTo(size.width, size.height);
    path2.close();

    // Paint wave 2 (back wave - semi transparent teal/indigo)
    final wavePaint2 = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0x336366F1), Color(0x6614B8A6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(
              0,
              baseHeight - 10,
              size.width,
              size.height - baseHeight + 10,
            ),
          );
    canvas.drawPath(path2, wavePaint2);

    // Paint wave 1 (front wave - solid teal/indigo gradient)
    final wavePaint1 = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0x994F46E5), Color(0xCC0D9488)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(
              0,
              baseHeight - 10,
              size.width,
              size.height - baseHeight + 10,
            ),
          );
    canvas.drawPath(path1, wavePaint1);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.waveAnimationValue != waveAnimationValue ||
        oldDelegate.fillPercentage != fillPercentage;
  }
}

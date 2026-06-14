import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class BmiCalculatorBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const BmiCalculatorBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<BmiCalculatorBubble> createState() =>
      _BmiCalculatorBubbleState();
}

class _BmiCalculatorBubbleState extends ConsumerState<BmiCalculatorBubble> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize({
            'heightCm': widget.initialData['heightCm'] ?? 175.0,
            'weightKg': widget.initialData['weightKg'] ?? 70.0,
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widgetStateNotifierProvider(widget.widgetId));
    if (state.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryStart),
        ),
      );
    }

    final double height = (state['heightCm'] as num?)?.toDouble() ?? 175.0;
    final double weight = (state['weightKg'] as num?)?.toDouble() ?? 70.0;

    // Calculate BMI
    final double heightM = height / 100.0;
    final double bmi = heightM > 0 ? (weight / (heightM * heightM)) : 0.0;

    // Determine category and styling
    String category = 'Normal';
    Color categoryColor = AppColors.accentEmerald;
    String advice =
        'Your weight is in the healthy range. Keep up the great work!';

    if (bmi < 18.5) {
      category = 'Underweight';
      categoryColor = AppColors.accentCyan;
      advice =
          'Consider a slight calorie surplus focusing on nutrient-dense foods and strength training.';
    } else if (bmi >= 18.5 && bmi < 25.0) {
      category = 'Normal';
      categoryColor = AppColors.accentEmerald;
      advice =
          'Perfect! Maintain your balanced nutrition and consistent exercise habits.';
    } else if (bmi >= 25.0 && bmi < 30.0) {
      category = 'Overweight';
      categoryColor = AppColors.accentOrange;
      advice =
          'A minor calorie deficit paired with resistance training will help optimize body composition.';
    } else {
      category = 'Obese';
      categoryColor = AppColors.accentRose;
      advice =
          'Focus on sustainable lifestyle modifications, including moderate activity and portion control.';
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'BMI Calculator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Interactive Body Metrics',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.calculate_outlined,
                color: AppColors.secondaryStart,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circle indicator representing BMI value
          Center(
            child: Column(
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: categoryColor,
                  ),
                ),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sliders
          _SliderRow(
            label: 'Height',
            value: height,
            min: 100,
            max: 250,
            unit: 'cm',
            onChanged: (val) => _updateMetric('heightCm', val),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'Weight',
            value: weight,
            min: 30,
            max: 200,
            unit: 'kg',
            onChanged: (val) => _updateMetric('weightKg', val),
          ),
          const SizedBox(height: 20),

          // Card advice box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              advice,
              style: TextStyle(
                fontSize: 12.5,
                color: categoryColor.withValues(alpha: 0.95),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateMetric(String key, double value) {
    ref
        .read(widgetStateNotifierProvider(widget.widgetId).notifier)
        .updateState((current) => {...current, key: value});
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${value.toInt()} $unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

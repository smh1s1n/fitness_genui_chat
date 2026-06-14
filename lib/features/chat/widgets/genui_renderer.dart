import 'package:flutter/material.dart';
import '../models/genui_widget_data.dart';
import '../../fitness/widgets/water_tracker_bubble.dart';
import '../../fitness/widgets/workout_logger_bubble.dart';
import '../../fitness/widgets/macro_tracker_bubble.dart';
import '../../fitness/widgets/fitness_timer_bubble.dart';
import '../../fitness/widgets/bmi_calculator_bubble.dart';
import '../../fitness/widgets/progress_chart_bubble.dart';

class GenUIRenderer extends StatelessWidget {
  final GenUIWidgetData widgetData;

  const GenUIRenderer({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    switch (widgetData.type) {
      case 'water_tracker':
        return WaterTrackerBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      case 'workout_logger':
        return WorkoutLoggerBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      case 'macro_tracker':
        return MacroTrackerBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      case 'fitness_timer':
        return FitnessTimerBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      case 'bmi_calculator':
        return BmiCalculatorBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      case 'progress_chart':
        return ProgressChartBubble(
          widgetId: widgetData.id,
          initialData: widgetData.data,
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unknown interactive widget: ${widgetData.type}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class MacroTrackerBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const MacroTrackerBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<MacroTrackerBubble> createState() => _MacroTrackerBubbleState();
}

class _MacroTrackerBubbleState extends ConsumerState<MacroTrackerBubble> {
  bool _showAddForm = false;
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize(widget.initialData);
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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

    final mealName = state['mealName'] as String? ?? 'Nutrition Log';
    final calories = (state['calories'] as num?)?.toDouble() ?? 0.0;
    final protein = (state['protein'] as num?)?.toDouble() ?? 0.0;
    final carbs = (state['carbs'] as num?)?.toDouble() ?? 0.0;
    final fat = (state['fat'] as num?)?.toDouble() ?? 0.0;

    // Daily reference limits for visual bar ratio
    const double refProtein = 150.0;
    const double refCarbs = 250.0;
    final double refFat = 70.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Macronutrients Breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${calories.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Protein, Carbs, Fat macro rings or indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroIndicator(
                label: 'Protein',
                value: protein,
                unit: 'g',
                ratio: protein / refProtein,
                color: AppColors.primaryStart,
              ),
              _MacroIndicator(
                label: 'Carbs',
                value: carbs,
                unit: 'g',
                ratio: carbs / refCarbs,
                color: AppColors.secondaryStart,
              ),
              _MacroIndicator(
                label: 'Fat',
                value: fat,
                unit: 'g',
                ratio: fat / refFat,
                color: AppColors.accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_showAddForm)
            ElevatedButton.icon(
              onPressed: () => setState(() => _showAddForm = true),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Meal Component'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glassWhite,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )
          else ...[
            const Divider(color: AppColors.border, height: 24),
            const Text(
              'Quick Add Food',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'kcal',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'P (g)',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'C (g)',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'F (g)',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _showAddForm = false),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCustomFood,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    backgroundColor: AppColors.secondaryStart,
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _addCustomFood() {
    final foodName = _foodNameController.text.trim();
    final addedCal = double.tryParse(_caloriesController.text) ?? 0.0;
    final addedP = double.tryParse(_proteinController.text) ?? 0.0;
    final addedC = double.tryParse(_carbsController.text) ?? 0.0;
    final addedF = double.tryParse(_fatController.text) ?? 0.0;

    if (addedCal == 0 && addedP == 0 && addedC == 0 && addedF == 0) {
      return;
    }

    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final name = current['mealName'] as String? ?? 'Nutrition Log';
        final currentCal = (current['calories'] as num?)?.toDouble() ?? 0.0;
        final currentP = (current['protein'] as num?)?.toDouble() ?? 0.0;
        final currentC = (current['carbs'] as num?)?.toDouble() ?? 0.0;
        final currentF = (current['fat'] as num?)?.toDouble() ?? 0.0;

        return {
          ...current,
          'mealName': foodName.isNotEmpty ? '$name + $foodName' : name,
          'calories': currentCal + addedCal,
          'protein': currentP + addedP,
          'carbs': currentC + addedC,
          'fat': currentF + addedF,
        };
      },
    );

    // Clear inputs and hide form
    _foodNameController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
    setState(() => _showAddForm = false);
  }
}

class _MacroIndicator extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double ratio;
  final Color color;

  const _MacroIndicator({
    required this.label,
    required this.value,
    required this.unit,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double boundedRatio = ratio.clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: boundedRatio,
                backgroundColor: AppColors.border.withValues(alpha: 0.3),
                color: color,
                strokeWidth: 5,
              ),
            ),
            Column(
              children: [
                Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class WorkoutLoggerBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const WorkoutLoggerBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<WorkoutLoggerBubble> createState() =>
      _WorkoutLoggerBubbleState();
}

class _WorkoutLoggerBubbleState extends ConsumerState<WorkoutLoggerBubble> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Map simple exercise model to stateful workout representation
      final Map<String, dynamic> processedData = {};
      processedData['workoutName'] =
          widget.initialData['workoutName'] ?? 'Workout Log';

      final rawExercises = widget.initialData['exercises'] as List? ?? [];
      final List<Map<String, dynamic>> exercises = [];

      for (final raw in rawExercises) {
        final exerciseName = raw['name'] as String? ?? 'Exercise';
        final setCount = (raw['sets'] as num?)?.toInt() ?? 3;
        final reps = (raw['reps'] as num?)?.toInt() ?? 10;
        final weight = (raw['weightKg'] as num?)?.toDouble() ?? 0.0;

        final List<Map<String, dynamic>> setsList = List.generate(
          setCount,
          (index) => {
            'setId': index + 1,
            'reps': reps,
            'weightKg': weight,
            'isCompleted': false,
          },
        );

        exercises.add({'name': exerciseName, 'sets': setsList});
      }

      processedData['exercises'] = exercises;

      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize(processedData);
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

    final workoutName = state['workoutName'] as String? ?? 'Workout';
    final exercises = state['exercises'] as List? ?? [];

    // Calculate total sets and completed sets for overall progress
    int totalSets = 0;
    int completedSets = 0;

    for (final exercise in exercises) {
      final sets = exercise['sets'] as List? ?? [];
      totalSets += sets.length;
      for (final s in sets) {
        if (s['isCompleted'] == true) {
          completedSets++;
        }
      }
    }

    final progress = totalSets > 0 ? (completedSets / totalSets) : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completedSets of $totalSets sets completed',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.fitness_center_outlined,
                color: AppColors.primaryStart,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryStart,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Exercise list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.border, height: 24),
            itemBuilder: (context, exIndex) {
              final exercise = exercises[exIndex] as Map;
              final String name = exercise['name'] ?? '';
              final List sets = exercise['sets'] as List? ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sets table-like list
                  ...List.generate(sets.length, (setIdx) {
                    final setItem = sets[setIdx] as Map;
                    final int setId = setItem['setId'] ?? 1;
                    final int reps = setItem['reps'] ?? 10;
                    final double weight =
                        (setItem['weightKg'] as num?)?.toDouble() ?? 0.0;
                    final bool isDone = setItem['isCompleted'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          // Set number label
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.primaryStart.withValues(
                                      alpha: 0.15,
                                    )
                                  : AppColors.border.withValues(alpha: 0.5),
                            ),
                            child: Text(
                              '$setId',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? AppColors.primaryStart
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Adjusters stacked vertically to avoid horizontal overflow
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Weight adjuster Row
                                Row(
                                  children: [
                                    const Icon(Icons.fitness_center_outlined, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    _smallClickable(
                                      icon: Icons.remove,
                                      onTap: isDone
                                          ? null
                                          : () => _updateSetWeight(
                                              exIndex,
                                              setIdx,
                                              -2.5,
                                            ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${weight.toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDone
                                            ? AppColors.textMuted
                                            : AppColors.textPrimary,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    _smallClickable(
                                      icon: Icons.add,
                                      onTap: isDone
                                          ? null
                                          : () => _updateSetWeight(
                                              exIndex,
                                              setIdx,
                                              2.5,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Reps adjuster Row
                                Row(
                                  children: [
                                    const Icon(Icons.repeat, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    _smallClickable(
                                      icon: Icons.remove,
                                      onTap: isDone
                                          ? null
                                          : () => _updateSetReps(
                                              exIndex,
                                              setIdx,
                                              -1,
                                            ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$reps reps',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDone
                                            ? AppColors.textMuted
                                            : AppColors.textPrimary,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    _smallClickable(
                                      icon: Icons.add,
                                      onTap: isDone
                                          ? null
                                          : () => _updateSetReps(
                                              exIndex,
                                              setIdx,
                                              1,
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Checkbox button
                          IconButton(
                            icon: Icon(
                              isDone
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isDone
                                  ? AppColors.accentEmerald
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _toggleSetCompletion(exIndex, setIdx),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _smallClickable({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? AppColors.textMuted : AppColors.secondaryStart,
        ),
      ),
    );
  }

  void _updateSetWeight(int exerciseIndex, int setIndex, double delta) {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final List exercises = List.from(current['exercises']);
        final Map exercise = Map.from(exercises[exerciseIndex]);
        final List sets = List.from(exercise['sets']);
        final Map setItem = Map.from(sets[setIndex]);

        final double currentWeight =
            (setItem['weightKg'] as num?)?.toDouble() ?? 0.0;
        setItem['weightKg'] = (currentWeight + delta).clamp(0.0, 500.0);

        sets[setIndex] = setItem;
        exercise['sets'] = sets;
        exercises[exerciseIndex] = exercise;

        return {...current, 'exercises': exercises};
      },
    );
  }

  void _updateSetReps(int exerciseIndex, int setIndex, int delta) {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final List exercises = List.from(current['exercises']);
        final Map exercise = Map.from(exercises[exerciseIndex]);
        final List sets = List.from(exercise['sets']);
        final Map setItem = Map.from(sets[setIndex]);

        final int currentReps = (setItem['reps'] as num?)?.toInt() ?? 0;
        setItem['reps'] = (currentReps + delta).clamp(1, 100);

        sets[setIndex] = setItem;
        exercise['sets'] = sets;
        exercises[exerciseIndex] = exercise;

        return {...current, 'exercises': exercises};
      },
    );
  }

  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final List exercises = List.from(current['exercises']);
        final Map exercise = Map.from(exercises[exerciseIndex]);
        final List sets = List.from(exercise['sets']);
        final Map setItem = Map.from(sets[setIndex]);

        final bool currentVal = setItem['isCompleted'] ?? false;
        setItem['isCompleted'] = !currentVal;

        sets[setIndex] = setItem;
        exercise['sets'] = sets;
        exercises[exerciseIndex] = exercise;

        return {...current, 'exercises': exercises};
      },
    );
  }
}

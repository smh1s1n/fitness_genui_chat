import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class FitnessTimerBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const FitnessTimerBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<FitnessTimerBubble> createState() => _FitnessTimerBubbleState();
}

class _FitnessTimerBubbleState extends ConsumerState<FitnessTimerBubble> {
  Timer? _localTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize({
            'durationSeconds': widget.initialData['durationSeconds'] ?? 60,
            'label': widget.initialData['label'] ?? 'Timer',
            'isRunning': false,
            'pausedRemainingSeconds':
                widget.initialData['durationSeconds'] ?? 60,
            'endTimeIso': null,
          });

      // Start tick check loop
      _startLocalTicker();
    });
  }

  @override
  void dispose() {
    _localTicker?.cancel();
    super.dispose();
  }

  void _startLocalTicker() {
    _localTicker?.cancel();
    _localTicker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;

      final state = ref.read(widgetStateNotifierProvider(widget.widgetId));
      if (state.isEmpty || state['isRunning'] != true) return;

      final endTimeIso = state['endTimeIso'] as String?;
      if (endTimeIso == null) return;

      final endTime = DateTime.parse(endTimeIso);
      final now = DateTime.now();

      if (now.isAfter(endTime)) {
        // Timer completed!
        _completeTimer();
      } else {
        // Trigger rebuild to update countdown display
        setState(() {});
      }
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

    final duration = (state['durationSeconds'] as num?)?.toInt() ?? 60;
    final label = state['label'] as String? ?? 'Timer';
    final isRunning = state['isRunning'] == true;
    final pausedRemaining =
        (state['pausedRemainingSeconds'] as num?)?.toInt() ?? duration;
    final endTimeIso = state['endTimeIso'] as String?;

    int remainingSeconds = pausedRemaining;
    if (isRunning && endTimeIso != null) {
      final endTime = DateTime.parse(endTimeIso);
      remainingSeconds = endTime.difference(DateTime.now()).inSeconds;
      if (remainingSeconds < 0) remainingSeconds = 0;
    }

    final double progress = duration > 0 ? (remainingSeconds / duration) : 0.0;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                isRunning ? Icons.timer_outlined : Icons.timer_off_outlined,
                color: isRunning
                    ? AppColors.secondaryStart
                    : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Circle Countdown and time string
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border.withValues(alpha: 0.3),
                    color: isRunning
                        ? AppColors.secondaryStart
                        : AppColors.primaryStart,
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: remainingSeconds == 0
                        ? AppColors.accentRose
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Control actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              _TimerControlButton(
                icon: Icons.replay_outlined,
                color: AppColors.textSecondary,
                onTap: _resetTimer,
              ),
              const SizedBox(width: 24),

              // Play / Pause
              _TimerControlButton(
                icon: isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: isRunning
                    ? AppColors.accentOrange
                    : AppColors.accentEmerald,
                isLarge: true,
                onTap: isRunning ? _pauseTimer : _startTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final pausedRemaining =
            (current['pausedRemainingSeconds'] as num?)?.toInt() ?? 60;
        final endTime = DateTime.now().add(Duration(seconds: pausedRemaining));

        return {
          ...current,
          'isRunning': true,
          'endTimeIso': endTime.toIso8601String(),
        };
      },
    );
    _startLocalTicker();
  }

  void _pauseTimer() {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final endTimeIso = current['endTimeIso'] as String?;
        int remaining = 0;
        if (endTimeIso != null) {
          remaining = DateTime.parse(
            endTimeIso,
          ).difference(DateTime.now()).inSeconds;
          if (remaining < 0) remaining = 0;
        }

        return {
          ...current,
          'isRunning': false,
          'pausedRemainingSeconds': remaining,
          'endTimeIso': null,
        };
      },
    );
  }

  void _resetTimer() {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final duration = (current['durationSeconds'] as num?)?.toInt() ?? 60;
        return {
          ...current,
          'isRunning': false,
          'pausedRemainingSeconds': duration,
          'endTimeIso': null,
        };
      },
    );
    setState(() {});
  }

  void _completeTimer() {
    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        return {
          ...current,
          'isRunning': false,
          'pausedRemainingSeconds': 0,
          'endTimeIso': null,
        };
      },
    );
    setState(() {});
  }
}

class _TimerControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const _TimerControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isLarge ? 54 : 42;
    return Material(
      color: color.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: isLarge ? 32 : 20),
        ),
      ),
    );
  }
}

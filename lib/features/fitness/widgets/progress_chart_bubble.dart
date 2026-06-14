import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/providers/genui_providers.dart';

class ProgressChartBubble extends ConsumerStatefulWidget {
  final String widgetId;
  final Map<String, dynamic> initialData;

  const ProgressChartBubble({
    super.key,
    required this.widgetId,
    required this.initialData,
  });

  @override
  ConsumerState<ProgressChartBubble> createState() =>
      _ProgressChartBubbleState();
}

class _ProgressChartBubbleState extends ConsumerState<ProgressChartBubble> {
  int _selectedPointIndex = -1;
  bool _isBarChart = false;
  final _newValueController = TextEditingController();
  String? _selectedDay;

  @override
  void initState() {
    super.initState();
    
    // Default to the current day of the week
    final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final currentDayIndex = DateTime.now().weekday - 1;
    _selectedDay = dayNames[currentDayIndex.clamp(0, 6)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(widgetStateNotifierProvider(widget.widgetId).notifier)
          .initialize({
            'chartType': widget.initialData['chartType'] ?? 'weight',
            'title': widget.initialData['title'] ?? 'Weekly Progress',
            'labels': List<String>.from(widget.initialData['labels'] ?? []),
            'values': List<double>.from(
              (widget.initialData['values'] as List?)?.map(
                    (e) => (e as num).toDouble(),
                  ) ??
                  [],
            ),
          });
    });
  }

  @override
  void dispose() {
    _newValueController.dispose();
    super.dispose();
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

    final chartType = state['chartType'] as String? ?? 'weight';
    final title = state['title'] as String? ?? 'Progress';
    final labels = List<String>.from(state['labels'] ?? []);
    final values = List<double>.from(state['values'] ?? []);

    final unit = chartType == 'weight'
        ? 'kg'
        : (chartType == 'steps' ? 'steps' : 'kcal');

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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _selectedPointIndex != -1 &&
                              _selectedPointIndex < values.length
                          ? '${labels[_selectedPointIndex]}: ${values[_selectedPointIndex].toStringAsFixed(1)} $unit'
                          : 'Tap points to inspect data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedPointIndex != -1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedPointIndex != -1
                            ? AppColors.secondaryStart
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Chart style toggle button
              IconButton(
                icon: Icon(
                  _isBarChart
                      ? Icons.show_chart_rounded
                      : Icons.bar_chart_rounded,
                  color: AppColors.primaryStart,
                ),
                onPressed: () => setState(() => _isBarChart = !_isBarChart),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Paint Area with Gesture Detector to detect taps
          LayoutBuilder(
            builder: (context, constraints) {
              final double chartWidth = constraints.maxWidth;
              const double chartHeight = 160.0;

              return GestureDetector(
                onTapDown: (details) {
                  final double x = details.localPosition.dx;
                  if (values.isEmpty) return;

                  // Find which label interval is closest to x
                  final double stepX = chartWidth / (values.length - 1);
                  int closestIndex = -1;
                  double minDistance = double.infinity;

                  for (int i = 0; i < values.length; i++) {
                    final double pointX = i * stepX;
                    final double dist = (pointX - x).abs();
                    if (dist < minDistance && dist < (stepX / 2)) {
                      minDistance = dist;
                      closestIndex = i;
                    }
                  }

                  setState(() {
                    _selectedPointIndex = closestIndex;
                  });
                },
                child: CustomPaint(
                  size: Size(chartWidth, chartHeight),
                  painter: CustomChartPainter(
                    labels: labels,
                    values: values,
                    selectedIndex: _selectedPointIndex,
                    isBar: _isBarChart,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Quick entry logger row
          Row(
            children: [
              // Day of the week dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    items: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        .map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      if (val != null) {
                        setState(() {
                          _selectedDay = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _newValueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Log ($unit)...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addNewLogPoint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  backgroundColor: AppColors.primaryStart,
                ),
                child: const Text('Log', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addNewLogPoint() {
    final double? val = double.tryParse(_newValueController.text);
    if (val == null || val <= 0) return;

    ref.read(widgetStateNotifierProvider(widget.widgetId).notifier).updateState(
      (current) {
        final List<String> labels = List.from(current['labels']);
        final List<double> values = List.from(
          (current['values'] as List).map((e) => (e as num).toDouble()),
        );

        final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        
        // Check if the selected day already has a log entry
        final index = labels.indexOf(_selectedDay ?? 'Mon');
        if (index != -1) {
          // Update the existing entry
          values[index] = val;
        } else {
          // If the list is full (7 days), remove the first one to keep 7 slots
          if (labels.length >= 7) {
            labels.removeAt(0);
            values.removeAt(0);
          }
          
          labels.add(_selectedDay ?? 'Mon');
          values.add(val);

          // Chronologically sort labels and values according to weekly day order
          final List<MapEntry<String, double>> paired = List.generate(
            labels.length,
            (i) => MapEntry(labels[i], values[i]),
          );
          paired.sort((a, b) => dayNames.indexOf(a.key).compareTo(dayNames.indexOf(b.key)));

          labels.clear();
          values.clear();
          for (final entry in paired) {
            labels.add(entry.key);
            values.add(entry.value);
          }
        }

        return {...current, 'labels': labels, 'values': values};
      },
    );

    _newValueController.clear();
    setState(() {
      _selectedPointIndex = -1;
    });
  }
}

class CustomChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final int selectedIndex;
  final bool isBar;

  CustomChartPainter({
    required this.labels,
    required this.values,
    required this.selectedIndex,
    required this.isBar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    // Chart margins
    const double bottomMargin = 20.0;
    const double topMargin = 15.0;
    const double leftMargin = 10.0;
    const double rightMargin = 10.0;

    final double drawHeight = height - bottomMargin - topMargin;
    final double drawWidth = width - leftMargin - rightMargin;

    // Calculate dynamic scales
    final double minVal = values.reduce(min);
    final double maxVal = values.reduce(max);
    final double valueRange = (maxVal - minVal).abs() < 0.1
        ? 1.0
        : (maxVal - minVal);

    // Padding values for chart min/max
    final double yMin = minVal - (valueRange * 0.15);
    final double yMax = maxVal + (valueRange * 0.15);
    final double yRange = yMax - yMin;

    final double stepX = values.length > 1
        ? (drawWidth / (values.length - 1))
        : drawWidth;

    // Coordinate translation helper
    Offset getPointOffset(int index) {
      final double x = leftMargin + (index * stepX);
      // Invert Y coordinate since canvas 0 is top
      final double y =
          topMargin + drawHeight * (1.0 - ((values[index] - yMin) / yRange));
      return Offset(x, y);
    }

    // 1. Draw Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final double yGrid = topMargin + (drawHeight / 2) * i;
      canvas.drawLine(
        Offset(leftMargin, yGrid),
        Offset(width - rightMargin, yGrid),
        gridPaint,
      );
    }

    if (isBar) {
      // 2a. Draw Bar Chart
      final double barWidth = min(stepX * 0.5, 30.0);
      final double baselineY = topMargin + drawHeight; // Bottom coordinate

      for (int i = 0; i < values.length; i++) {
        final Offset pt = getPointOffset(i);
        final bool isSelected = i == selectedIndex;

        final paint = Paint()
          ..shader =
              LinearGradient(
                colors: isSelected
                    ? [AppColors.secondaryStart, AppColors.accentCyan]
                    : [
                        AppColors.primaryStart.withValues(alpha: 0.7),
                        AppColors.primaryStart,
                      ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ).createShader(
                Rect.fromPoints(Offset(pt.dx - barWidth / 2, baselineY), pt),
              );

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            pt.dx - barWidth / 2,
            pt.dy,
            pt.dx + barWidth / 2,
            baselineY,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(rect, paint);

        // Selection highlight ring
        if (isSelected) {
          final borderPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawRRect(rect, borderPaint);
        }
      }
    } else {
      // 2b. Draw Line Chart with Bezier Smooth curve
      final path = Path();
      final fillPath = Path();

      final Offset pt0 = getPointOffset(0);
      path.moveTo(pt0.dx, pt0.dy);
      fillPath.moveTo(pt0.dx, topMargin + drawHeight);
      fillPath.lineTo(pt0.dx, pt0.dy);

      for (int i = 0; i < values.length - 1; i++) {
        final Offset pCurrent = getPointOffset(i);
        final Offset pNext = getPointOffset(i + 1);

        // Control points for cubic bezier smoothing
        final double controlX1 = pCurrent.dx + (pNext.dx - pCurrent.dx) / 2;
        final double controlY1 = pCurrent.dy;
        final double controlX2 = pCurrent.dx + (pNext.dx - pCurrent.dx) / 2;
        final double controlY2 = pNext.dy;

        path.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          pNext.dx,
          pNext.dy,
        );
        fillPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          pNext.dx,
          pNext.dy,
        );
      }

      fillPath.lineTo(
        getPointOffset(values.length - 1).dx,
        topMargin + drawHeight,
      );
      fillPath.close();

      // Draw Gradient fill
      final fillPaint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                AppColors.primaryStart.withValues(alpha: 0.35),
                AppColors.primaryStart.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTWH(leftMargin, topMargin, drawWidth, drawHeight),
            );
      canvas.drawPath(fillPath, fillPaint);

      // Draw Line path
      final linePaint = Paint()
        ..color = AppColors.primaryStart
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      // 3. Draw Points
      for (int i = 0; i < values.length; i++) {
        final Offset pt = getPointOffset(i);
        final bool isSelected = i == selectedIndex;

        final ptPaint = Paint()
          ..color = isSelected ? AppColors.secondaryStart : Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(pt, isSelected ? 6.0 : 4.0, ptPaint);

        if (isSelected) {
          final ringPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(pt, 10.0, ringPaint);
        }
      }
    }

    // 4. Draw X labels
    const textStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < labels.length; i++) {
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final Offset pt = getPointOffset(i);
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, height - bottomMargin + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isBar != isBar ||
        oldDelegate.values != values ||
        oldDelegate.labels != labels;
  }
}

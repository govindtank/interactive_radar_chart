import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/radar_data.dart';

/// Interactive radar / spider chart where users can drag polygon vertices
/// along radial axes to adjust values in real-time.
class InteractiveRadarChart extends StatefulWidget {
  const InteractiveRadarChart({
    super.key,
    required this.dataSets,
    this.onValuesChanged,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.step,
    this.theme,
    this.enableHaptics = true,
  }) : assert(minValue < maxValue,
            'minValue must be strictly less than maxValue');

  final List<RadarDataSet> dataSets;
  final ValueChanged<List<double>>? onValuesChanged;
  final double minValue;
  final double maxValue;
  final double? step;
  final InteractiveRadarTheme? theme;
  final bool enableHaptics;

  @override
  State<InteractiveRadarChart> createState() => _InteractiveRadarChartState();
}

class _InteractiveRadarChartState extends State<InteractiveRadarChart> {
  int? _activeVertexIndex;
  double _lastSnappedValue = -1.0;

  double _normalize(double val) {
    return ((val - widget.minValue) / (widget.maxValue - widget.minValue))
        .clamp(0.0, 1.0);
  }

  double _denormalize(double norm) {
    return widget.minValue + norm * (widget.maxValue - widget.minValue);
  }

  void _handlePanStart(
      Offset localPos, Size size, RadarDataSet interactiveSet) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.72;
    final count = interactiveSet.entries.length;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i - (pi / 2);
      final norm = _normalize(interactiveSet.entries[i].value);
      final vertexPos =
          center + Offset(cos(angle), sin(angle)) * (radius * norm);

      if ((localPos - vertexPos).distance <= 28.0) {
        setState(() => _activeVertexIndex = i);
        _lastSnappedValue = interactiveSet.entries[i].value;
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        break;
      }
    }
  }

  void _handlePanUpdate(
      Offset localPos, Size size, RadarDataSet interactiveSet) {
    if (_activeVertexIndex == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.72;
    final count = interactiveSet.entries.length;
    final idx = _activeVertexIndex!;
    final angle = (2 * pi / count) * idx - (pi / 2);

    final touchVector = localPos - center;
    final axisUnitVector = Offset(cos(angle), sin(angle));

    // Project touch vector onto radial axis unit vector
    final projection =
        touchVector.dx * axisUnitVector.dx + touchVector.dy * axisUnitVector.dy;
    final normDistance = (projection / radius).clamp(0.0, 1.0);

    double rawValue = _denormalize(normDistance);

    // Magnetic snap to step if configured
    if (widget.step != null && widget.step! > 0) {
      final step = widget.step!;
      rawValue = (rawValue / step).round() * step;
      rawValue = rawValue.clamp(widget.minValue, widget.maxValue);

      if (widget.enableHaptics &&
          (rawValue - _lastSnappedValue).abs() >= step) {
        HapticFeedback.selectionClick();
        _lastSnappedValue = rawValue;
      }
    }

    final newEntries = List<RadarEntry>.from(interactiveSet.entries);
    newEntries[idx] = newEntries[idx].copyWith(value: rawValue);

    final allValues = newEntries.map((e) => e.value).toList();
    widget.onValuesChanged?.call(allValues);
  }

  void _handlePanEnd() {
    setState(() => _activeVertexIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? InteractiveRadarTheme.dark()
            : InteractiveRadarTheme.light());

    final interactiveSet = widget.dataSets.firstWhere(
      (s) => s.isInteractive,
      orElse: () => widget.dataSets.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (d) =>
              _handlePanStart(d.localPosition, size, interactiveSet),
          onPanUpdate: (d) =>
              _handlePanUpdate(d.localPosition, size, interactiveSet),
          onPanEnd: (_) => _handlePanEnd(),
          onPanCancel: () => _handlePanEnd(),
          child: CustomPaint(
            size: size,
            painter: _RadarChartPainter(
              dataSets: widget.dataSets,
              theme: activeTheme,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
              activeVertexIndex: _activeVertexIndex,
            ),
          ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.dataSets,
    required this.theme,
    required this.minValue,
    required this.maxValue,
    required this.activeVertexIndex,
  });

  final List<RadarDataSet> dataSets;
  final InteractiveRadarTheme theme;
  final double minValue;
  final double maxValue;
  final int? activeVertexIndex;

  double _normalize(double val) {
    return ((val - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dataSets.isEmpty || dataSets.first.entries.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.72;
    final entriesCount = dataSets.first.entries.length;

    // 1. Draw Background Concentric Grid
    final gridPaint = Paint()
      ..color = theme.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int div = 1; div <= theme.divisions; div++) {
      final divRadius = radius * (div / theme.divisions);

      if (theme.gridShape == RadarGridShape.circle) {
        canvas.drawCircle(center, divRadius, gridPaint);
      } else {
        final polyPath = Path();
        for (int i = 0; i < entriesCount; i++) {
          final angle = (2 * pi / entriesCount) * i - (pi / 2);
          final pt = center + Offset(cos(angle), sin(angle)) * divRadius;
          if (i == 0) {
            polyPath.moveTo(pt.dx, pt.dy);
          } else {
            polyPath.lineTo(pt.dx, pt.dy);
          }
        }
        polyPath.close();
        canvas.drawPath(polyPath, gridPaint);
      }
    }

    // 2. Draw Radial Spokes and Axis Labels
    final axisPaint = Paint()
      ..color = theme.axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < entriesCount; i++) {
      final angle = (2 * pi / entriesCount) * i - (pi / 2);
      final spokeEnd = center + Offset(cos(angle), sin(angle)) * radius;
      canvas.drawLine(center, spokeEnd, axisPaint);

      // Label Drawing
      final labelOffset =
          center + Offset(cos(angle), sin(angle)) * (radius + 20.0);
      final labelText = dataSets.first.entries[i].label;

      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(
          color: theme.labelColor,
          fontSize: theme.labelFontSize,
          fontWeight: FontWeight.w600,
          fontFamily: theme.fontFamily,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelPos = Offset(
        labelOffset.dx - textPainter.width / 2,
        labelOffset.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelPos);
    }

    // 3. Draw Data Sets (Polygons & Handles)
    for (final set in dataSets) {
      final path = Path();
      final vertices = <Offset>[];

      for (int i = 0; i < entriesCount; i++) {
        final angle = (2 * pi / entriesCount) * i - (pi / 2);
        final norm = _normalize(set.entries[i].value);
        final pt = center + Offset(cos(angle), sin(angle)) * (radius * norm);
        vertices.add(pt);

        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();

      // Fill polygon
      final fillPaint = Paint()
        ..color = set.fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Stroke polygon outline
      final strokePaint = Paint()
        ..color = set.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = set.borderWidth;
      canvas.drawPath(path, strokePaint);

      // Draw Vertex Handles if interactive
      if (set.isInteractive) {
        for (int i = 0; i < vertices.length; i++) {
          final pt = vertices[i];
          final isActive = i == activeVertexIndex;

          final handlePaint = Paint()
            ..color = isActive ? theme.activeHandleColor : set.borderColor
            ..style = PaintingStyle.fill;

          canvas.drawCircle(pt,
              isActive ? set.entryRadius + 3.0 : set.entryRadius, handlePaint);

          // White center pip
          final pipPaint = Paint()..color = theme.handleColor;
          canvas.drawCircle(pt, set.entryRadius * 0.5, pipPaint);

          // Glowing ring around active dragging vertex
          if (isActive) {
            final ringPaint = Paint()
              ..color = theme.activeHandleColor.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0;
            canvas.drawCircle(pt, set.entryRadius + 8.0, ringPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}

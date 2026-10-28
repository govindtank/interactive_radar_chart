import 'package:flutter/material.dart';

/// The geometry shape of concentric background grid levels.
enum RadarGridShape {
  /// Regular polygon matching the number of axes (spider web).
  polygon,

  /// Smooth concentric circular rings.
  circle,
}

/// A single data point representing a feature attribute and its numerical value.
@immutable
class RadarEntry {
  const RadarEntry({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  RadarEntry copyWith({
    String? label,
    double? value,
  }) {
    return RadarEntry(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarEntry &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// A collection of [RadarEntry] items forming a polygon layer on the radar chart.
@immutable
class RadarDataSet {
  const RadarDataSet({
    required this.entries,
    this.fillColor = const Color(0x3310B981),
    this.borderColor = const Color(0xFF10B981),
    this.borderWidth = 2.0,
    this.entryRadius = 5.0,
    this.isInteractive = true,
    this.useCurvedPolygon = false,
  });

  final List<RadarEntry> entries;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double entryRadius;
  final bool isInteractive;
  final bool useCurvedPolygon;

  RadarDataSet copyWith({
    List<RadarEntry>? entries,
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    double? entryRadius,
    bool? isInteractive,
    bool? useCurvedPolygon,
  }) {
    return RadarDataSet(
      entries: entries ?? this.entries,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      entryRadius: entryRadius ?? this.entryRadius,
      isInteractive: isInteractive ?? this.isInteractive,
      useCurvedPolygon: useCurvedPolygon ?? this.useCurvedPolygon,
    );
  }
}

/// Visual styling configuration for [InteractiveRadarChart].
@immutable
class InteractiveRadarTheme {
  const InteractiveRadarTheme({
    required this.gridColor,
    required this.axisColor,
    required this.labelColor,
    required this.handleColor,
    required this.activeHandleColor,
    this.divisions = 4,
    this.gridShape = RadarGridShape.polygon,
    this.fontFamily,
    this.labelFontSize = 12.0,
    this.showDragTooltip = true,
  });

  final Color gridColor;
  final Color axisColor;
  final Color labelColor;
  final Color handleColor;
  final Color activeHandleColor;
  final int divisions;
  final RadarGridShape gridShape;
  final String? fontFamily;
  final double labelFontSize;
  final bool showDragTooltip;

  /// Sleek dark theme.
  factory InteractiveRadarTheme.dark() {
    return const InteractiveRadarTheme(
      gridColor: Color(0x33FFFFFF),
      axisColor: Color(0x4DFFFFFF),
      labelColor: Color(0xFFE4E4E7),
      handleColor: Colors.white,
      activeHandleColor: Color(0xFF38BDF8),
      divisions: 4,
      gridShape: RadarGridShape.polygon,
    );
  }

  /// Clean light theme.
  factory InteractiveRadarTheme.light() {
    return const InteractiveRadarTheme(
      gridColor: Color(0x26000000),
      axisColor: Color(0x33000000),
      labelColor: Color(0xFF18181B),
      handleColor: Color(0xFF09090B),
      activeHandleColor: Color(0xFF0284C7),
      divisions: 4,
      gridShape: RadarGridShape.polygon,
    );
  }

  /// Cyberpunk gaming theme with neon accents.
  factory InteractiveRadarTheme.cyberpunk() {
    return const InteractiveRadarTheme(
      gridColor: Color(0x33A855F7),
      axisColor: Color(0x4DA855F7),
      labelColor: Color(0xFFF472B6),
      handleColor: Color(0xFF06B6D4),
      activeHandleColor: Color(0xFFF43F5E),
      divisions: 5,
      gridShape: RadarGridShape.polygon,
    );
  }
}

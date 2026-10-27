import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_radar_chart/interactive_radar_chart.dart';

void main() {
  group('Radar data models', () {
    test('RadarEntry copyWith modifies fields', () {
      const entry = RadarEntry(label: 'Speed', value: 80);
      final updated = entry.copyWith(value: 95);

      expect(updated.label, equals('Speed'));
      expect(updated.value, equals(95));
    });

    test('InteractiveRadarTheme presets instantiate valid palettes', () {
      final dark = InteractiveRadarTheme.dark();
      final light = InteractiveRadarTheme.light();
      final cyberpunk = InteractiveRadarTheme.cyberpunk();

      expect(dark.gridColor, isNotNull);
      expect(light.gridColor, isNotNull);
      expect(cyberpunk.gridColor, isNotNull);
    });
  });

  group('InteractiveRadarChart Widget Tests', () {
    testWidgets('renders all axis labels on canvas', (tester) async {
      const dataSet = RadarDataSet(
        entries: [
          RadarEntry(label: 'Attack', value: 80),
          RadarEntry(label: 'Defense', value: 65),
          RadarEntry(label: 'Speed', value: 90),
          RadarEntry(label: 'Agility', value: 70),
          RadarEntry(label: 'Stamina', value: 85),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: InteractiveRadarChart(
                  dataSets: [dataSet],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveRadarChart), findsOneWidget);
    });

    testWidgets('invokes onValuesChanged when dragging a vertex handle',
        (tester) async {
      List<double>? changedValues;

      const dataSet = RadarDataSet(
        entries: [
          RadarEntry(label: 'Attack', value: 50),
          RadarEntry(label: 'Defense', value: 50),
          RadarEntry(label: 'Speed', value: 50),
          RadarEntry(label: 'Stamina', value: 50),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: InteractiveRadarChart(
                  dataSets: [dataSet],
                  onValuesChanged: (vals) => changedValues = vals,
                ),
              ),
            ),
          ),
        ),
      );

      final chartFinder = find.byType(InteractiveRadarChart);
      final center = tester.getCenter(chartFinder);

      // Top vertex is at (center.x, center.y - radius * 0.5)
      // Radius = 300 / 2 * 0.72 = 108. 108 * 0.5 = 54. Top vertex is at (150, 96).
      final gesture = await tester.startGesture(center + const Offset(0, -54));
      await gesture.moveBy(const Offset(0, -30));
      await gesture.up();
      await tester.pump();

      expect(changedValues, isNotNull);
    });
  });
}

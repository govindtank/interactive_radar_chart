import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('InteractiveRadarDemoApp smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InteractiveRadarDemoApp());
    expect(find.text('interactive_radar_chart'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });
}

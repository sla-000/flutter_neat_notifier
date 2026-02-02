import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_advanced/main.dart';

void main() {
  testWidgets('GIVEN: The App is running, '
      'WHEN: it builds for the first time, '
      'THEN: initial counter values are zero', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('NeatState Demo'), findsOneWidget);
  });

  testWidgets('GIVEN: The App is running, '
      'WHEN: Counter 2 button is tapped, '
      'THEN: Counter 2 is incremented in UI', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final btn2 = find.widgetWithText(FloatingActionButton, '2');
    await tester.tap(btn2);
    await tester.pump();

    // Counter 2 should be 1. Note: '1' is also on Button 1.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('GIVEN: The App is running with rebuild optimization, '
      'WHEN: Counter 3 is incremented, '
      'THEN: UI remains unchanged', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final btn3 = find.widgetWithText(FloatingActionButton, '3');
    await tester.tap(btn3);
    await tester.pump();

    // Optimization: UI should NOT rebuild for counter3, so values remain '0'
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('1'), findsOneWidget); // Only FAB 1
  });

  testWidgets('GIVEN: The App is running, '
      'WHEN: Counter 3 is tapped 5 times, '
      'THEN: a SnackBar milestone is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final btn3 = find.widgetWithText(FloatingActionButton, '3');

    for (var i = 0; i < 5; i++) {
      await tester.tap(btn3);
      await tester.pump();
    }

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Milestone reached: 5 items!'), findsOneWidget);
  });
}

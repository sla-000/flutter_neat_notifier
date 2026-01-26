import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('MyHomePage initial state test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    // Verify initial values
    expect(find.text('0'), findsNWidgets(3)); // Counter 1, 2, and 3
    // Buttons '1', '2', '3' are also present
    expect(find.text('1'), findsOneWidget); // Button 1
    expect(find.text('2'), findsOneWidget); // Button 2
    expect(find.text('3'), findsOneWidget); // Button 3
    expect(find.text('NeatState DI Demo'), findsOneWidget);
  });

  testWidgets('Increment Counter 2 button interaction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    // Find button 2 and tap it
    final btn2 = find.widgetWithText(FloatingActionButton, '2');
    await tester.tap(btn2);
    await tester.pump();

    // Counter 2 should be 1.
    // find.text('1') will find Counter 2 AND Button 1
    expect(find.text('1'), findsNWidgets(2));
    // Counter 1 and 3 should still be 0
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Increment Counter 3 button interaction (Optimization Test)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    // Find button 3 and tap it
    final btn3 = find.widgetWithText(FloatingActionButton, '3');
    await tester.tap(btn3);
    await tester.pump();

    // Counter 3 state changes, but UI does NOT rebuild due to rebuildWhen optimization
    // So Counter 3 text in UI still shows '0'
    expect(find.text('1'), findsOneWidget); // Only Button 1
    expect(find.text('0'), findsNWidgets(3)); // Counters 1, 2, and 3 (stale)
  });

  testWidgets('Milestone event shows SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final btn3 = find.widgetWithText(FloatingActionButton, '3');

    // Tap 5 times to trigger milestone
    for (var i = 0; i < 5; i++) {
      await tester.tap(btn3);
      await tester.pump();
    }

    // Verify snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Milestone reached: 5 items!'), findsOneWidget);
  });
}

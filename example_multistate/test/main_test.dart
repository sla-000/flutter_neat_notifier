import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_multistate/main.dart';

void main() {
  testWidgets('GIVEN: NeatMultiState is running, '
      'WHEN: counter is incremented, '
      'THEN: only the counter section updates', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Count: 0'), findsOneWidget);
    expect(find.text('Name: Guest'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
    expect(
      find.text('Name: Guest'),
      findsOneWidget,
    ); // User section should be unchanged
  });

  testWidgets('GIVEN: NeatMultiState is running, '
      'WHEN: user age is incremented, '
      'THEN: only the user section updates', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Age: 25'), findsOneWidget);
    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.text('Increment Age'));
    await tester.pump();

    expect(find.text('Age: 26'), findsOneWidget);
    expect(
      find.text('Count: 0'),
      findsOneWidget,
    ); // Counter should be unchanged
  });

  testWidgets('GIVEN: ThemeNotifier is present, '
      'WHEN: theme is toggled, '
      'THEN: the app theme changes', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Initially light mode
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('GIVEN: A notifier reaches a milestone, '
      'WHEN: incremented 5 times, '
      'THEN: a snackbar action is emitted', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.text('Increment'));
    }
    await tester.pumpAndSettle();

    expect(find.text('Milestone reached: 5'), findsOneWidget);
  });
}

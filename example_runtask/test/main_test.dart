import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_runtask/main.dart';

void main() {
  testWidgets('GIVEN: UserNotifier is at initial state, '
      'WHEN: the app is launched, '
      'THEN: it should show "No user data."', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('No user data.'), findsOneWidget);
  });

  testWidgets('GIVEN: UserNotifier is at initial state, '
      'WHEN: "Fetch Success" button is tapped, '
      'THEN: it should show the loading indicator.', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Fetch Success'));
    await tester.pump();
    expect(find.text('Loading user...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Cleanup: clear the pending timer
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('GIVEN: UserNotifier is loading, '
      'WHEN: the fetch task completes successfully, '
      'THEN: it should show the welcome message with the user name.', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Fetch Success'));
    await tester.pump();

    // Wait for delay
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Welcome, John Doe!'), findsOneWidget);
  });

  testWidgets('GIVEN: UserNotifier is loading, '
      'WHEN: the fetch task fails, '
      'THEN: it should show the error message and retry button.', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Fetch Error'));
    await tester.pump();

    // Wait for delay
    await tester.pump(const Duration(seconds: 2));

    expect(
      find.textContaining('Error: Exception: Failed to connect to the server'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('GIVEN: UserNotifier is in error state, '
      'WHEN: "Retry" button is tapped, '
      'THEN: it should return to loading state.', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Fetch Error'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Tap Retry
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading user...'), findsOneWidget);

    // Cleanup: clear the pending timer
    await tester.pump(const Duration(seconds: 2));
  });
}

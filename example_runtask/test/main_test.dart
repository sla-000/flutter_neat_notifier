import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_runtask/main.dart';

void main() {
  testWidgets('Initial state shows No user data.', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('No user data.'), findsOneWidget);
  });

  testWidgets('Fetch success updates the UI.', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap Fetch Success
    await tester.tap(find.text('Fetch Success'));
    await tester.pump();

    // Check loading
    expect(find.text('Loading user...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for delay
    await tester.pump(const Duration(seconds: 2));

    // Check resulting UI
    expect(find.text('Welcome, John Doe!'), findsOneWidget);
  });

  testWidgets('Fetch error shows error UI and retry works.', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Tap Fetch Error
    await tester.tap(find.text('Fetch Error'));
    await tester.pump();

    // Check loading
    expect(find.text('Loading user...'), findsOneWidget);

    // Wait for delay
    await tester.pump(const Duration(seconds: 2));

    // Check error UI
    expect(
      find.textContaining('Error: Exception: Failed to connect to the server'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    // Test Retry (success)
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading user...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Welcome, John Doe!'), findsOneWidget);
  });
}

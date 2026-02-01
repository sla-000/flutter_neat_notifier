import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_undoredo/main.dart';

void main() {
  testWidgets('GIVEN: Undo/Redo Example is running, '
      'WHEN: a todo is added, '
      'THEN: it appears in the list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Buy Milk');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Buy Milk'), findsOneWidget);
  });

  testWidgets('GIVEN: A todo is added, '
      'WHEN: undo is pressed, '
      'THEN: the todo is removed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Buy Milk');
    await tester.tap(find.text('Add'));
    await tester.pump();
    expect(find.text('Buy Milk'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();

    expect(find.text('Buy Milk'), findsNothing);
  });

  testWidgets('GIVEN: A todo was undone, '
      'WHEN: redo is pressed, '
      'THEN: the todo is restored', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Buy Milk');
    await tester.tap(find.text('Add'));
    await tester.pump();

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(find.text('Buy Milk'), findsNothing);

    await tester.tap(find.byTooltip('Redo'));
    await tester.pump();

    expect(find.text('Buy Milk'), findsOneWidget);
  });

  testWidgets('GIVEN: Multiple todos added, '
      'WHEN: redo is pressed, '
      'THEN: it restores the correct state sequentially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Task 1');
    await tester.tap(find.text('Add'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Task 2');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(find.text('Task 2'), findsNothing);
    expect(find.text('Task 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(find.text('Task 1'), findsNothing);

    await tester.tap(find.byTooltip('Redo'));
    await tester.pump();
    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsNothing);
  });
}

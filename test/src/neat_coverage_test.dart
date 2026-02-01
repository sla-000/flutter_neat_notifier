import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestNotifier extends NeatNotifier<int, String> {
  TestNotifier() : super(0);
}

void main() {
  testWidgets('GIVEN: No NeatState in tree, '
      'WHEN: NeatState.of is called, '
      'THEN: it throws FlutterError', (WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());

    expect(
      () => NeatState.of<TestNotifier>(tester.element(find.byType(SizedBox))),
      throwsA(
        isA<FlutterError>().having(
          (e) => e.message,
          'message',
          contains('NeatState.of() called with a context'),
        ),
      ),
    );
  });

  testWidgets('GIVEN: NeatState exists, '
      'WHEN: context.read is called, '
      'THEN: it returns the notifier without listening', (
    WidgetTester tester,
  ) async {
    final notifier = TestNotifier();
    int buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, int, String>(
          create: (_) => notifier,
          child: Builder(
            builder: (context) {
              buildCount++;
              final n = context.read<TestNotifier>();
              return Text('Count: ${n.value}');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    notifier.value = 1;
    await tester.pump();

    expect(
      buildCount,
      1,
    ); // Should NOT rebuild because context.read doesn't listen
  });

  testWidgets('GIVEN: NeatState exists, '
      'WHEN: context.watch is called, '
      'THEN: it returns the notifier and listens', (WidgetTester tester) async {
    final notifier = TestNotifier();
    int buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, int, String>(
          create: (_) => notifier,
          child: Builder(
            builder: (context) {
              buildCount++;
              final n = context.watch<TestNotifier>();
              return Text('Count: ${n.value}');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    notifier.value = 1;
    await tester.pump();

    expect(buildCount, 2); // Should rebuild
  });

  testWidgets('GIVEN: NeatState is used as a Consumer (no create), '
      'WHEN: dependencies change, '
      'THEN: it initializes from ancestor', (WidgetTester tester) async {
    final notifier = TestNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, int, String>(
          create: (_) => notifier,
          child: NeatState<TestNotifier, int, String>(
            builder: (context, state, child) {
              return Text('Nested Count: $state');
            },
          ),
        ),
      ),
    );

    expect(find.text('Nested Count: 0'), findsOneWidget);

    notifier.value = 1;
    await tester.pump();

    expect(find.text('Nested Count: 1'), findsOneWidget);
  });
}

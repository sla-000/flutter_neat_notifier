import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestState {
  final int count1;
  final int count2;
  TestState(this.count1, this.count2);
}

class TestNotifier extends NeatNotifier<TestState, dynamic> {
  TestNotifier() : super(TestState(0, 0));

  void increment1() {
    value = TestState(value.count1 + 1, value.count2);
  }

  void increment2() {
    value = TestState(value.count1, value.count2 + 1);
  }
}

void main() {
  testWidgets('GIVEN: A widget using context.select, '
      'WHEN: an unrelated part of the state changes, '
      'THEN: the widget does NOT rebuild', (WidgetTester tester) async {
    final notifier = TestNotifier();
    int buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, TestState, dynamic>(
          create: (_) => notifier,
          child: Builder(
            builder: (context) {
              buildCount++;
              final count1 = context.select<TestNotifier, TestState, int>(
                (s) => s.count1,
              );
              return Text('Count1: $count1');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);
    expect(find.text('Count1: 0'), findsOneWidget);

    // Increment 2 (unrelated to the selector)
    notifier.increment2();
    await tester.pump();

    expect(buildCount, 1); // Should NOT rebuild
  });

  testWidgets('GIVEN: A widget using context.select, '
      'WHEN: the selected part of the state changes, '
      'THEN: the widget rebuilds', (WidgetTester tester) async {
    final notifier = TestNotifier();
    int buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, TestState, dynamic>(
          create: (_) => notifier,
          child: Builder(
            builder: (context) {
              buildCount++;
              final count1 = context.select<TestNotifier, TestState, int>(
                (s) => s.count1,
              );
              return Text('Count1: $count1');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    // Increment 1 (related to the selector)
    notifier.increment1();
    await tester.pump();

    expect(buildCount, 2); // Should rebuild
    expect(find.text('Count1: 1'), findsOneWidget);
  });

  testWidgets('GIVEN: Multiple widgets with different selectors, '
      'WHEN: one specific part of state changes, '
      'THEN: only the relevant widget rebuilds', (WidgetTester tester) async {
    final notifier = TestNotifier();
    int buildCount1 = 0;
    int buildCount2 = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestNotifier, TestState, dynamic>(
          create: (_) => notifier,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  buildCount1++;
                  final c = context.select<TestNotifier, TestState, int>(
                    (s) => s.count1,
                  );
                  return Text('C1: $c');
                },
              ),
              Builder(
                builder: (context) {
                  buildCount2++;
                  final c = context.select<TestNotifier, TestState, int>(
                    (s) => s.count2,
                  );
                  return Text('C2: $c');
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(buildCount1, 1);
    expect(buildCount2, 1);

    // Trigger increment 1
    notifier.increment1();
    await tester.pump();

    expect(buildCount1, 2);
    expect(buildCount2, 1); // Should stay 1

    // Trigger increment 2
    notifier.increment2();
    await tester.pump();

    expect(buildCount1, 2); // Should stay 2
    expect(buildCount2, 2);
  });
}

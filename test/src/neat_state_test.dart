import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestValueNotifier extends NeatNotifier<int, dynamic> {
  TestValueNotifier() : super(0);

  bool isDisposed = false;

  void increment() {
    value++;
  }

  void triggerError() {
    setError('Test Error', StackTrace.current);
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  // Public wrappers for testing @protected methods
  void testSetLoading(NeatLoading? value) => setLoading(value);
  void testSetError(Object error, [StackTrace? stackTrace]) =>
      setError(error, stackTrace);
  void testClearError() => clearError();
}

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
  testWidgets('GIVEN: NeatState is initialized, '
      'WHEN: it builds for the first time, '
      'THEN: the notifier is created and initial UI is shown', (
    WidgetTester tester,
  ) async {
    TestValueNotifier? capturedNotifier;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) {
            capturedNotifier = TestValueNotifier();
            return capturedNotifier!;
          },
          builder: (context, state, child) {
            return Text('Count: $state');
          },
        ),
      ),
    );

    expect(capturedNotifier, isNotNull);
    expect(find.text('Count: 0'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatState is active, '
      'WHEN: the notifier updates its state, '
      'THEN: the widget rebuilds with new state', (WidgetTester tester) async {
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (context, state, child) {
            return Text('Count: $state');
          },
        ),
      ),
    );

    notifier.increment();
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatState is in the tree, '
      'WHEN: the widget is removed, '
      'THEN: the notifier is disposed', (WidgetTester tester) async {
    TestValueNotifier? capturedNotifier;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) {
            capturedNotifier = TestValueNotifier();
            return capturedNotifier!;
          },
          builder: (context, notifier, child) {
            return const SizedBox();
          },
        ),
      ),
    );

    expect(capturedNotifier!.isDisposed, isFalse);

    await tester.pumpWidget(const Placeholder());

    expect(capturedNotifier!.isDisposed, isTrue);
  });

  testWidgets('GIVEN: NeatState with rebuildWhen optimization, '
      'WHEN: a watched value changes, '
      'THEN: the widget rebuilds', (WidgetTester tester) async {
    int buildCount = 0;
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          rebuildWhen: (prev, curr) => curr > prev,
          builder: (context, state, child) {
            buildCount++;
            return Text('Count: $state');
          },
        ),
      ),
    );

    expect(buildCount, 1);

    notifier.increment(); // 1 > 0
    await tester.pump();

    expect(buildCount, 2);
    expect(find.text('Count: 1'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatState with rebuildWhen optimization, '
      'WHEN: an ignored value changes, '
      'THEN: the widget does NOT rebuild', (WidgetTester tester) async {
    int buildCount = 0;
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          rebuildWhen: (prev, curr) => false, // Never rebuild
          builder: (context, state, child) {
            buildCount++;
            return Text('Count: $state');
          },
        ),
      ),
    );

    expect(buildCount, 1);

    notifier.increment();
    await tester.pump();

    expect(buildCount, 1); // Should still be 1
  });

  testWidgets('GIVEN: NeatState with errorBuilder, '
      'WHEN: the notifier has an error, '
      'THEN: the errorBuilder is shown', (WidgetTester tester) async {
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (_, _, _) => const Text('Normal Content'),
          errorBuilder: (context, error, child) {
            return Text('Error: ${error.error}');
          },
        ),
      ),
    );

    expect(find.text('Normal Content'), findsOneWidget);

    notifier.triggerError();
    await tester.pump();

    expect(find.text('Error: Test Error'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatState in error state, '
      'WHEN: the error is cleared, '
      'THEN: the normal builder is restored', (WidgetTester tester) async {
    final notifier = TestValueNotifier();
    notifier.triggerError();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (_, _, _) => const Text('Normal Content'),
          errorBuilder: (context, error, child) {
            return const Text('Error UI');
          },
        ),
      ),
    );

    expect(find.text('Error UI'), findsOneWidget);

    notifier.testClearError();
    await tester.pump();

    expect(find.text('Normal Content'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatState with loadingBuilder, '
      'WHEN: the notifier is loading, '
      'THEN: the loadingBuilder is shown', (WidgetTester tester) async {
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (_, _, _) => const Text('Normal Content'),
          loadingBuilder: (context, loading, child) {
            return const Text('Loading UI');
          },
        ),
      ),
    );

    expect(find.text('Normal Content'), findsOneWidget);

    notifier.testSetLoading((isUploading: false, progress: 0));
    await tester.pump();

    expect(find.text('Loading UI'), findsOneWidget);

    notifier.testSetLoading(null);
    await tester.pump();

    expect(find.text('Normal Content'), findsOneWidget);
  });

  testWidgets('GIVEN: NeatNotifier using runTask, '
      'WHEN: an async task is executed, '
      'THEN: it automatically manages loading and error states', (
    WidgetTester tester,
  ) async {
    final notifier = TestValueNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (context, state, child) =>
              const Text('Loading: false, Error: false'),
          errorBuilder: (_, _, _) => const Text('Error State'),
          loadingBuilder: (_, _, _) => const Text('Loading State'),
        ),
      ),
    );

    expect(find.text('Loading: false, Error: false'), findsOneWidget);

    // Start async task
    final task = notifier.runTask(() async {
      await Future.delayed(const Duration(milliseconds: 100));
    });

    await tester.pump();
    expect(find.text('Loading State'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await task;
    await tester.pump();

    expect(find.text('Loading: false, Error: false'), findsOneWidget);

    // Test error handling in runTask
    final errorTask = notifier.runTask(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('runTask Error');
    });

    await tester.pump();
    expect(find.text('Loading State'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await errorTask;
    await tester.pump();

    expect(find.text('Error State'), findsOneWidget);
  });

  group('context.select', () {
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
  });

  testWidgets('GIVEN: NeatState with onAction, '
      'WHEN: an action is emitted, '
      'THEN: the onAction callback is triggered', (WidgetTester tester) async {
    final notifier = TestValueNotifier();
    String? receivedAction;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          builder: (_, _, _) => const Text('Content'),
          onAction: (context, action) {
            receivedAction = action as String;
          },
        ),
      ),
    );

    notifier.emitAction('test_action');
    await tester.pump(); // Pump to process stream

    expect(receivedAction, 'test_action');
  });

  testWidgets('GIVEN: NeatState with a shared child, '
      'WHEN: switching between loading, error, and normal states, '
      'THEN: the child is preserved and passed to all builders', (
    WidgetTester tester,
  ) async {
    final notifier = TestValueNotifier();
    const childKey = Key('shared-child');
    const sharedChild = Text('Shared Child', key: childKey);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NeatState<TestValueNotifier, int, dynamic>(
          create: (_) => notifier,
          child: sharedChild,
          builder: (_, _, child) =>
              Column(children: [const Text('Normal'), child!]),
          loadingBuilder: (_, _, child) =>
              Column(children: [const Text('Loading'), child!]),
          errorBuilder: (_, _, child) =>
              Column(children: [const Text('Error'), child!]),
        ),
      ),
    );

    // Normal state
    expect(find.text('Normal'), findsOneWidget);
    expect(find.byKey(childKey), findsOneWidget);

    // Loading state
    notifier.testSetLoading((isUploading: false, progress: 0));
    await tester.pump();
    expect(find.text('Loading'), findsOneWidget);
    expect(find.byKey(childKey), findsOneWidget);

    // Error state
    notifier.testSetLoading(null);
    notifier.triggerError();
    await tester.pump();
    expect(find.text('Error'), findsOneWidget);
    expect(find.byKey(childKey), findsOneWidget);
  });
}

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
  void testSetLoading(bool value) => setLoading(value);
  void testSetError(Object error, [StackTrace? stackTrace]) =>
      setError(error, stackTrace);
  void testClearError() => clearError();
}

void main() {
  testWidgets(
    '''GIVEN: NeatBuilder is initialized
WHEN: it builds for the first time
THEN: the notifier is created and initial UI is shown''',
    (WidgetTester tester) async {
      TestValueNotifier? capturedNotifier;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) {
              capturedNotifier = TestValueNotifier();
              return capturedNotifier!;
            },
            builder: (context, notifier, child) {
              return Text('Count: ${notifier.value}');
            },
          ),
        ),
      );

      expect(capturedNotifier, isNotNull);
      expect(find.text('Count: 0'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder is active
WHEN: the notifier updates its state
THEN: the widget rebuilds with new state''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (context, n, child) {
              return Text('Count: ${n.value}');
            },
          ),
        ),
      );

      notifier.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder is in the tree
WHEN: the widget is removed
THEN: the notifier is disposed''',
    (WidgetTester tester) async {
      TestValueNotifier? capturedNotifier;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
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
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with rebuildWhen optimization
WHEN: a watched value changes
THEN: the widget rebuilds''',
    (WidgetTester tester) async {
      int buildCount = 0;
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            rebuildWhen: (prev, curr) => curr > prev,
            builder: (context, n, child) {
              buildCount++;
              return Text('Count: ${n.value}');
            },
          ),
        ),
      );

      expect(buildCount, 1);

      notifier.increment(); // 1 > 0
      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('Count: 1'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with rebuildWhen optimization
WHEN: an ignored value changes
THEN: the widget does NOT rebuild''',
    (WidgetTester tester) async {
      int buildCount = 0;
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            rebuildWhen: (prev, curr) => false, // Never rebuild
            builder: (context, n, child) {
              buildCount++;
              return Text('Count: ${n.value}');
            },
          ),
        ),
      );

      expect(buildCount, 1);

      notifier.increment();
      await tester.pump();

      expect(buildCount, 1); // Should still be 1
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with errorBuilder
WHEN: the notifier has an error
THEN: the errorBuilder is shown''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (_, _, _) => const Text('Normal Content'),
            errorBuilder: (context, error, stackTrace, n, child) {
              return Text('Error: $error');
            },
          ),
        ),
      );

      expect(find.text('Normal Content'), findsOneWidget);

      notifier.triggerError();
      await tester.pump();

      expect(find.text('Error: Test Error'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder in error state
WHEN: the error is cleared
THEN: the normal builder is restored''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();
      notifier.triggerError();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (_, _, _) => const Text('Normal Content'),
            errorBuilder: (context, error, stackTrace, n, child) {
              return const Text('Error UI');
            },
          ),
        ),
      );

      expect(find.text('Error UI'), findsOneWidget);

      notifier.testClearError();
      await tester.pump();

      expect(find.text('Normal Content'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with loadingBuilder
WHEN: the notifier is loading
THEN: the loadingBuilder is shown''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (_, _, _) => const Text('Normal Content'),
            loadingBuilder: (context, n, child) {
              return const Text('Loading UI');
            },
          ),
        ),
      );

      expect(find.text('Normal Content'), findsOneWidget);

      notifier.testSetLoading(true);
      await tester.pump();

      expect(find.text('Loading UI'), findsOneWidget);

      notifier.testSetLoading(false);
      await tester.pump();

      expect(find.text('Normal Content'), findsOneWidget);
    },
  );

  testWidgets(
    '''GIVEN: NeatNotifier using runTask
WHEN: an async task is executed
THEN: it automatically manages loading and error states''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (_, n, _) =>
                Text('Loading: ${n.isLoading}, Error: ${n.error != null}'),
            errorBuilder: (_, _, _, _, _) => const Text('Error State'),
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
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with onEvent
WHEN: an event is emitted
THEN: the onEvent callback is triggered''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();
      String? receivedEvent;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            builder: (_, _, _) => const Text('Content'),
            onEvent: (context, notifier, event) {
              receivedEvent = event as String;
            },
          ),
        ),
      );

      notifier.emitEvent('test_event');
      await tester.pump(); // Pump to process stream

      expect(receivedEvent, 'test_event');
    },
  );

  testWidgets(
    '''GIVEN: NeatBuilder with a shared child
WHEN: switching between loading, error, and normal states
THEN: the child is preserved and passed to all builders''',
    (WidgetTester tester) async {
      final notifier = TestValueNotifier();
      const childKey = Key('shared-child');
      const sharedChild = Text('Shared Child', key: childKey);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NeatBuilder<TestValueNotifier, int, dynamic>(
            create: (_) => notifier,
            child: sharedChild,
            builder: (_, _, child) =>
                Column(children: [const Text('Normal'), child!]),
            loadingBuilder: (_, _, child) =>
                Column(children: [const Text('Loading'), child!]),
            errorBuilder: (_, _, _, _, child) =>
                Column(children: [const Text('Error'), child!]),
          ),
        ),
      );

      // Normal state
      expect(find.text('Normal'), findsOneWidget);
      expect(find.byKey(childKey), findsOneWidget);

      // Loading state
      notifier.testSetLoading(true);
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
      expect(find.byKey(childKey), findsOneWidget);

      // Error state
      notifier.testSetLoading(false);
      notifier.triggerError();
      await tester.pump();
      expect(find.text('Error'), findsOneWidget);
      expect(find.byKey(childKey), findsOneWidget);
    },
  );
}

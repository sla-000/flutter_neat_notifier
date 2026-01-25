import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestNotifier extends NeatNotifier<int, dynamic> {
  TestNotifier() : super(0);

  // Public wrappers for testing @protected methods
  void testSetLoading(bool value) => setLoading(value);
  void testSetError(Object error, [StackTrace? stackTrace]) =>
      setError(error, stackTrace);
  void testClearError() => clearError();
}

void main() {
  group('NeatNotifier', () {
    test(
      '''GIVEN: A new NeatNotifier
WHEN: it is initialized
THEN: it has default values for value, error, and isLoading''',
      () {
        final notifier = TestNotifier();

        expect(notifier.value, 0);
        expect(notifier.error, isNull);
        expect(notifier.stackTrace, isNull);
        expect(notifier.isLoading, isFalse);
      },
    );

    test(
      '''GIVEN: A NeatNotifier
WHEN: setError is called
THEN: it updates error and stackTrace and notifies listeners''',
      () {
        final notifier = TestNotifier();
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        final error = Exception('test');
        final stackTrace = StackTrace.current;
        notifier.testSetError(error, stackTrace);

        expect(notifier.error, error);
        expect(notifier.stackTrace, stackTrace);
        expect(notifyCount, 1);
      },
    );

    test(
      '''GIVEN: A NeatNotifier with an error
WHEN: clearError is called
THEN: it resets error and stackTrace and notifies listeners''',
      () {
        final notifier = TestNotifier();
        notifier.testSetError(Exception('test'));

        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        notifier.testClearError();

        expect(notifier.error, isNull);
        expect(notifier.stackTrace, isNull);
        expect(notifyCount, 1);
      },
    );

    test(
      '''GIVEN: A NeatNotifier
WHEN: setLoading is called
THEN: it updates isLoading and notifies listeners''',
      () {
        final notifier = TestNotifier();
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        notifier.testSetLoading(true);
        expect(notifier.isLoading, isTrue);
        expect(notifyCount, 1);

        notifier.testSetLoading(false);
        expect(notifier.isLoading, isFalse);
        expect(notifyCount, 2);
      },
    );

    test(
      '''GIVEN: A NeatNotifier with Events
WHEN: emitEvent is called
THEN: the event is added to the events stream''',
      () async {
        final notifier = NeatNotifier<int, String>(0);
        const eventMessage = 'Test Event';

        final expectation = expectLater(notifier.events, emits(eventMessage));
        notifier.emitEvent(eventMessage);
        await expectation;
      },
    );

    group('runTask', () {
      test(
        '''GIVEN: A NeatNotifier
WHEN: runTask completes successfully
THEN: it manages loading state and updates value''',
        () async {
          final notifier = TestNotifier();
          final List<bool> loadingStates = [];
          notifier.addListener(() => loadingStates.add(notifier.isLoading));

          await notifier.runTask(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            notifier.value = 1;
          });

          expect(notifier.value, 1);
          expect(notifier.isLoading, isFalse);
          expect(loadingStates.contains(true), isTrue);
          expect(loadingStates.last, isFalse);
        },
      );

      test(
        '''GIVEN: A NeatNotifier
WHEN: runTask throws an error
THEN: it catches the error and moves to error state''',
        () async {
          final notifier = TestNotifier();
          final error = Exception('task failure');

          await notifier.runTask(() async {
            throw error;
          });

          expect(notifier.isLoading, isFalse);
          expect(notifier.error, error);
        },
      );

      test(
        '''GIVEN: A NeatNotifier already loading
WHEN: runTask is called again
THEN: the second task is ignored''',
        () async {
          final notifier = TestNotifier();
          int callCount = 0;

          final task1 = notifier.runTask(() async {
            callCount++;
            await Future.delayed(const Duration(milliseconds: 50));
          });

          final task2 = notifier.runTask(() async {
            callCount++;
          });

          await task1;
          await task2;

          expect(callCount, 1);
        },
      );
    });
  });
}

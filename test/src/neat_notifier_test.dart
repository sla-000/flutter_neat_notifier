import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestNotifier extends NeatNotifier<int, dynamic> {
  TestNotifier() : super(0);

  // Public wrappers for testing @protected methods
  void testSetLoading(NeatLoading? value) => setLoading(value);
  void testSetError(Object error, [StackTrace? stackTrace]) =>
      setError(error, stackTrace);
  void testClearError() => clearError();
}

void main() {
  group('NeatNotifier', () {
    test('GIVEN: A new NeatNotifier, '
        'WHEN: it is initialized, '
        'THEN: it should have the initial value', () {
      final notifier = TestNotifier();
      expect(notifier.value, 0);
    });

    test('GIVEN: A new NeatNotifier, '
        'WHEN: it is initialized, '
        'THEN: it should have no error', () {
      final notifier = TestNotifier();
      expect(notifier.error, isNull);
    });

    test('GIVEN: A new NeatNotifier, '
        'WHEN: it is initialized, '
        'THEN: it should not be loading', () {
      final notifier = TestNotifier();
      expect(notifier.isLoading, isFalse);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: setError is called, '
        'THEN: it should update the error object', () {
      final notifier = TestNotifier();
      final error = Exception('test');
      notifier.testSetError(error);
      expect(notifier.error, error);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: setError is called with a stack trace, '
        'THEN: it should update the stack trace', () {
      final notifier = TestNotifier();
      final stackTrace = StackTrace.current;
      notifier.testSetError(Exception('test'), stackTrace);
      expect(notifier.stackTrace, stackTrace);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: setError is called, '
        'THEN: it should notify listeners', () {
      final notifier = TestNotifier();
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);
      notifier.testSetError(Exception('test'));
      expect(notifyCount, 1);
    });

    test('GIVEN: A NeatNotifier with an error, '
        'WHEN: clearError is called, '
        'THEN: it should reset the error to null', () {
      final notifier = TestNotifier();
      notifier.testSetError(Exception('test'));
      notifier.testClearError();
      expect(notifier.error, isNull);
    });

    test('GIVEN: A NeatNotifier with an error, '
        'WHEN: clearError is called, '
        'THEN: it should notify listeners', () {
      final notifier = TestNotifier();
      notifier.testSetError(Exception('test'));
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);
      notifier.testClearError();
      expect(notifyCount, 1);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: setLoading is called with true, '
        'THEN: isLoading should be true', () {
      final notifier = TestNotifier();
      notifier.testSetLoading((isUploading: false, progress: 0));
      expect(notifier.isLoading, isTrue);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: setLoading is called with true, '
        'THEN: it should notify listeners', () {
      final notifier = TestNotifier();
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);
      notifier.testSetLoading((isUploading: false, progress: 0));
      expect(notifyCount, 1);
    });

    test('GIVEN: A NeatNotifier currently loading, '
        'WHEN: setLoading is called with null, '
        'THEN: isLoading should be false', () {
      final notifier = TestNotifier();
      notifier.testSetLoading((isUploading: false, progress: 0));
      notifier.testSetLoading(null);
      expect(notifier.isLoading, isFalse);
    });

    test('GIVEN: A NeatNotifier with Actions, '
        'WHEN: emitAction is called, '
        'THEN: the action is added to the actions stream', () async {
      final notifier = NeatNotifier<int, String>(0);
      const actionMessage = 'Test Action';

      final expectation = expectLater(notifier.actions, emits(actionMessage));
      notifier.emitAction(actionMessage);
      await expectation;
    });

    group('runTask', () {
      test('GIVEN: A NeatNotifier, '
          'WHEN: runTask completes successfully, '
          'THEN: it should update the value', () async {
        final notifier = TestNotifier();
        await notifier.runTask(() async {
          notifier.value = 1;
        });
        expect(notifier.value, 1);
      });

      test('GIVEN: A NeatNotifier, '
          'WHEN: runTask starts, '
          'THEN: it should enter loading state', () async {
        final notifier = TestNotifier();
        bool wasLoading = false;
        final taskDone = Completer<void>();

        final taskFuture = notifier.runTask(() async {
          wasLoading = notifier.isLoading;
          await taskDone.future;
        });

        // Wait a tick for task to start
        await Future.delayed(Duration.zero);
        expect(wasLoading, isTrue);

        taskDone.complete();
        await taskFuture;
      });

      test('GIVEN: A NeatNotifier, '
          'WHEN: runTask fails, '
          'THEN: it should record the error', () async {
        final notifier = TestNotifier();
        final error = Exception('task failed');

        await notifier.runTask(() async {
          throw error;
        });

        expect(notifier.error, error);
      });

      test('GIVEN: A NeatNotifier already loading, '
          'WHEN: runTask is called again, '
          'THEN: it should skip the second execution', () async {
        final notifier = TestNotifier();
        int executionCount = 0;
        final task1Started = Completer<void>();
        final task1Finish = Completer<void>();

        final f1 = notifier.runTask(() async {
          executionCount++;
          task1Started.complete();
          await task1Finish.future;
        });

        await task1Started.future;
        final f2 = notifier.runTask(() async {
          executionCount++;
        });

        await f2;
        task1Finish.complete();
        await f1;

        expect(executionCount, 1);
      });
    });
  });
}

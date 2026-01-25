import 'package:flutter_test/flutter_test.dart';
import 'package:ext_notifier/ext_notifier.dart';

class TestNotifier extends ExtValueNotifier<int> {
  TestNotifier() : super(0);
}

void main() {
  group('ExtValueNotifier', () {
    test(
      '''GIVEN: A new ExtValueNotifier
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
      '''GIVEN: An ExtValueNotifier
WHEN: setError is called
THEN: it updates error and stackTrace and notifies listeners''',
      () {
        final notifier = TestNotifier();
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        final error = Exception('test');
        final stackTrace = StackTrace.current;
        notifier.setError(error, stackTrace);

        expect(notifier.error, error);
        expect(notifier.stackTrace, stackTrace);
        expect(notifyCount, 1);
      },
    );

    test(
      '''GIVEN: An ExtValueNotifier with an error
WHEN: clearError is called
THEN: it resets error and stackTrace and notifies listeners''',
      () {
        final notifier = TestNotifier();
        notifier.setError(Exception('test'));

        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        notifier.clearError();

        expect(notifier.error, isNull);
        expect(notifier.stackTrace, isNull);
        expect(notifyCount, 1);
      },
    );

    test(
      '''GIVEN: An ExtValueNotifier
WHEN: setLoading is called
THEN: it updates isLoading and notifies listeners''',
      () {
        final notifier = TestNotifier();
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        notifier.setLoading(true);
        expect(notifier.isLoading, isTrue);
        expect(notifyCount, 1);

        notifier.setLoading(false);
        expect(notifier.isLoading, isFalse);
        expect(notifyCount, 2);
      },
    );

    group('runTask', () {
      test(
        '''GIVEN: An ExtValueNotifier
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
          // 1. setLoading(true)
          // 2. clearError() - no change, but runTask calls it.
          //    Wait, clearError calls notifyListeners even if no error was present?
          //    Let's check logic: clearError calls notifyListeners.
          // 3. value = 1
          // 4. setLoading(false)
          expect(loadingStates.contains(true), isTrue);
          expect(loadingStates.last, isFalse);
        },
      );

      test(
        '''GIVEN: An ExtValueNotifier
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
        '''GIVEN: An ExtValueNotifier already loading
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

import 'package:flutter_test/flutter_test.dart';
import 'package:example/counter_notifier.dart';

void main() {
  group('CounterNotifier', () {
    test('GIVEN: A new CounterNotifier, '
        'WHEN: initialized, '
        'THEN: initial state values are zero', () {
      final notifier = CounterNotifier();
      expect(notifier.value.counter1, 0);
      expect(notifier.value.counter2, 0);
      expect(notifier.value.counter3, 0);
      expect(notifier.isLoading, isFalse);
      expect(notifier.error, isNull);
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: increment2 is called, '
        'THEN: only counter2 is updated', () {
      final notifier = CounterNotifier();
      notifier.increment2();
      expect(notifier.value.counter2, 1);
      expect(notifier.value.counter1, 0);
      expect(notifier.value.counter3, 0);
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: increment3 is called 5 times, '
        'THEN: counter3 reaches 5 and a milestone action is emitted', () async {
      final notifier = CounterNotifier();
      final actions = <CounterAction>[];
      final subscription = notifier.actions.listen(actions.add);

      for (var i = 0; i < 5; i++) {
        notifier.increment3();
      }

      expect(notifier.value.counter3, 5);

      // Give the stream a moment to emit
      await Future.delayed(Duration.zero);

      expect(actions.length, 1);
      expect(actions.first, isA<CounterMilestoneAction>());
      final action = actions.first as CounterMilestoneAction;
      expect(action.message, contains('5 items'));

      await subscription.cancel();
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: increment1 (async) is called, '
        'THEN: it enters loading state', () async {
      final notifier = CounterNotifier();
      final future = notifier.increment1();

      expect(notifier.isLoading, isTrue);

      try {
        await future;
      } catch (_) {}

      expect(notifier.isLoading, isFalse);
    });
  });
}

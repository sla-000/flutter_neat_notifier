import 'package:flutter_test/flutter_test.dart';
import 'package:example/counter_notifier.dart';

void main() {
  group('CounterNotifier', () {
    late CounterNotifier notifier;

    setUp(() {
      notifier = CounterNotifier();
    });

    test('initial state is correct', () {
      expect(notifier.value.counter1, 0);
      expect(notifier.value.counter2, 0);
      expect(notifier.value.counter3, 0);
      expect(notifier.isLoading, isFalse);
      expect(notifier.error, isNull);
    });

    test('increment2 updates counter2', () {
      notifier.increment2();
      expect(notifier.value.counter2, 1);
      expect(notifier.value.counter1, 0);
      expect(notifier.value.counter3, 0);
    });

    test('increment3 updates counter3 and emits events', () async {
      final events = <CounterEvent>[];
      final subscription = notifier.events.listen(events.add);

      // 4 increments - no event
      for (var i = 0; i < 4; i++) {
        notifier.increment3();
      }
      expect(notifier.value.counter3, 4);
      expect(events, isEmpty);

      // 5th increment - milestone event
      notifier.increment3();
      expect(notifier.value.counter3, 5);

      // Give the stream a moment to emit
      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first, isA<CounterMilestoneEvent>());
      final event = events.first as CounterMilestoneEvent;
      expect(event.message, contains('5 items'));

      await subscription.cancel();
    });

    test('increment1 (async) handles loading state', () async {
      final future = notifier.increment1();

      // Should be loading immediately
      expect(notifier.isLoading, isTrue);

      // Wait for completion (simulated 1s delay in code)
      // Note: In real world, we'd use fake async, but here we'll just wait or pump
      try {
        await future;
      } catch (_) {
        // Safe to ignore random error in this specific test
      }

      expect(notifier.isLoading, isFalse);
    });
  });
}

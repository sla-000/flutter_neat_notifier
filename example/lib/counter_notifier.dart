import 'package:ext_notifier/ext_notifier.dart';

// 1. Define your State (using a Record for simplicity and immutability)
typedef CounterState = ({int counter1, int counter2, int counter3});

// 2. Define your Events (using a sealed class for type-safe handling)
sealed class CounterEvent {}

class CounterMilestoneEvent extends CounterEvent {
  CounterMilestoneEvent(this.message);
  final String message;
}

// 3. Define your Notifier (extending ExtValueNotifier with CounterEvent)
class CounterValueNotifier
    extends ExtValueNotifier<CounterState, CounterEvent> {
  CounterValueNotifier() : super((counter1: 0, counter2: 0, counter3: 0));

  Future<void> increment1() => runTask(() async {
    // Simulate async repository call
    await Future.delayed(const Duration(seconds: 1));

    // Simulate a random error (50% chance)
    if (DateTime.now().millisecond % 2 == 0) {
      throw Exception('Failed to update counter 1. Try again!');
    }

    value = (
      counter1: value.counter1 + 1,
      counter2: value.counter2,
      counter3: value.counter3,
    );
  });

  void increment2() {
    value = (
      counter1: value.counter1,
      counter2: value.counter2 + 1,
      counter3: value.counter3,
    );
  }

  void increment3() {
    value = (
      counter1: value.counter1,
      counter2: value.counter2,
      counter3: value.counter3 + 1,
    );

    // Emit event on milestone (every 5 increments)
    if (value.counter3 % 5 == 0) {
      emitEvent(
        CounterMilestoneEvent('Milestone reached: ${value.counter3} items!'),
      );
    }
  }
}

import 'package:neat_state/neat_state.dart';

// Define your State, everything is acceptable, record, equatable, freezed, etc.
typedef CounterState = ({int counter1, int counter2, int counter3});

// Define your Actions
sealed class CounterAction {}

class CounterMilestoneAction extends CounterAction {
  CounterMilestoneAction(this.message);
  final String message;
}

class CounterNotifier extends NeatNotifier<CounterState, CounterAction>
    with NeatUndoRedoNotifier<CounterState, CounterAction> {
  CounterNotifier() : super((counter1: 0, counter2: 0, counter3: 0));

  Future<void> increment1() => runTask(() async {
    // Simulate async repository call
    await Future.delayed(const Duration(milliseconds: 500));

    setLoading((isUploading: false, progress: 50));

    // Simulate a random error (50% chance)
    if (DateTime.now().millisecond % 2 == 0) {
      throw Exception('Failed to update counter 1. Try again!');
    }

    await Future.delayed(const Duration(milliseconds: 500));

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

    // Emit action on milestone (every 5 increments)
    if (value.counter3 % 5 == 0) {
      emitAction(
        CounterMilestoneAction('Milestone reached: ${value.counter3} items!'),
      );
    }
  }
}

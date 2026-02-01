import 'package:neat_state/neat_state.dart';

class CounterNotifier extends NeatNotifier<int, void>
    with NeatHydratedNotifier<int, void> {
  CounterNotifier() : super(0) {
    hydrate();
  }

  @override
  String get id => 'counter_persistence';

  void increment() => value++;
  void decrement() => value--;

  @override
  int? fromJson(Map<String, dynamic> json) => json['count'] as int?;

  @override
  Map<String, dynamic> toJson(int state) => {'count': state};
}

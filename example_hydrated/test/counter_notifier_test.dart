import 'package:flutter_test/flutter_test.dart';
import 'package:example_hydrated/counter_notifier.dart';
import 'package:neat_state/neat_state.dart';

class MockStorage implements NeatStorage {
  Map<String, Object?> data = {};
  @override
  Object? read(String key) => data[key];
  @override
  Future<void> write(String key, Object? value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }

  @override
  Future<void> clear() async {
    data.clear();
  }
}

void main() {
  group('CounterNotifier', () {
    setUp(() {
      NeatHydratedStorage.initialize(MockStorage());
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: increment is called, '
        'THEN: value increases', () {
      final notifier = CounterNotifier();
      expect(notifier.value, 0);
      notifier.increment();
      expect(notifier.value, 1);
    });
  });
}

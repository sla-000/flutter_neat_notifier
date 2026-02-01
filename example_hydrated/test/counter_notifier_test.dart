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

    test('GIVEN: CounterNotifier, '
        'WHEN: decrement is called, '
        'THEN: value decreases', () {
      final notifier = CounterNotifier();
      notifier.increment();
      expect(notifier.value, 1);
      notifier.decrement();
      expect(notifier.value, 0);
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: fromJson is called with valid data, '
        'THEN: it returns the correct integer value', () {
      final notifier = CounterNotifier();
      final result = notifier.fromJson({'count': 42});
      expect(result, 42);
    });

    test('GIVEN: CounterNotifier, '
        'WHEN: toJson is called, '
        'THEN: it returns the correct JSON map', () {
      final notifier = CounterNotifier();
      final json = notifier.toJson(42);
      expect(json, {'count': 42});
    });
  });
}

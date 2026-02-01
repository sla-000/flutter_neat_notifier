import 'package:flutter_test/flutter_test.dart';
import 'package:neat_state/neat_state.dart';

class MockStorage implements NeatStorage {
  final Map<String, Object?> data = {};

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

class HydratedCounter extends NeatNotifier<int, String>
    with NeatHydratedNotifier<int, String> {
  HydratedCounter() : super(0) {
    hydrate();
  }

  @override
  String get id => 'counter';

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;

  @override
  Map<String, dynamic> toJson(int state) => {'value': state};
}

void main() {
  late MockStorage storage;

  setUp(() {
    storage = MockStorage();
    NeatHydratedStorage.initialize(storage);
  });

  test('GIVEN: A HydratedCounter, '
      'WHEN: it is initialized with no stored data, '
      'THEN: it uses the initial value', () {
    final counter = HydratedCounter();
    expect(counter.value, 0);
  });

  test('GIVEN: A HydratedCounter, '
      'WHEN: its value changes, '
      'THEN: it is automatically saved to storage', () async {
    final counter = HydratedCounter();
    counter.value = 10;

    // We don't need to wait for write because it's async in interface but
    // the implementation (MockStorage) updates immediately in our case.
    // In real scenario, it might be eventually consistent.
    expect(storage.data['counter'], {'value': 10});
  });

  test('GIVEN: Stored data exists, '
      'WHEN: a new HydratedCounter is initialized, '
      'THEN: it restores its value from storage', () {
    storage.data['counter'] = {'value': 42};

    final counter = HydratedCounter();
    expect(counter.value, 42);
  });

  test('GIVEN: Malformed stored data, '
      'WHEN: a HydratedCounter is initialized, '
      'THEN: it falls back to the initial value', () {
    storage.data['counter'] = 'invalid data';

    final counter = HydratedCounter();
    expect(counter.value, 0);
  });
}

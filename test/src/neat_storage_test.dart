import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

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

void main() {
  group('NeatHydratedStorage', () {
    test('GIVEN: NeatHydratedStorage is NOT initialized, '
        'WHEN: storage is accessed, '
        'THEN: it throws StateError', () {
      expect(() => NeatHydratedStorage.storage, throwsStateError);
    });

    test('GIVEN: NeatHydratedStorage is initialized, '
        'WHEN: storage is accessed, '
        'THEN: it returns the provided storage instance', () {
      final storage = MockStorage();
      NeatHydratedStorage.initialize(storage);
      expect(NeatHydratedStorage.storage, storage);
    });
  });
}

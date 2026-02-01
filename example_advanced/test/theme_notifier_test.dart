import 'package:flutter_test/flutter_test.dart';
import 'package:example_advanced/theme_notifier.dart';
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
  group('ThemeNotifier', () {
    setUp(() {
      NeatHydratedStorage.initialize(MockStorage());
    });

    test('GIVEN: ThemeNotifier, '
        'WHEN: toggle is called, '
        'THEN: value changes', () {
      final notifier = ThemeNotifier();
      expect(notifier.value, isFalse);
      notifier.toggle();
      expect(notifier.value, isTrue);
    });
  });
}

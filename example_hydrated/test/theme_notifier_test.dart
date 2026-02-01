import 'package:flutter_test/flutter_test.dart';
import 'package:example_hydrated/theme_notifier.dart';
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
        'THEN: themeMode changes', () {
      final notifier = ThemeNotifier();
      expect(notifier.value, false);
      notifier.toggle();
      expect(notifier.value, true);
    });

    test('GIVEN: ThemeNotifier, '
        'WHEN: fromJson is called with valid data, '
        'THEN: it returns the correct boolean value', () {
      final notifier = ThemeNotifier();
      final result = notifier.fromJson({'isDarkMode': true});
      expect(result, isTrue);
    });

    test('GIVEN: ThemeNotifier, '
        'WHEN: toJson is called, '
        'THEN: it returns the correct JSON map', () {
      final notifier = ThemeNotifier();
      final json = notifier.toJson(true);
      expect(json, {'isDarkMode': true});
    });
  });
}

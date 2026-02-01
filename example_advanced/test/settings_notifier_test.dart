import 'package:flutter_test/flutter_test.dart';
import 'package:example_advanced/settings_notifier.dart';

void main() {
  group('SettingsNotifier', () {
    test('GIVEN: SettingsNotifier, '
        'WHEN: toggleDarkMode is called, '
        'THEN: state changes and action is emitted', () {
      final notifier = SettingsNotifier();
      expect(notifier.value.isDarkMode, isFalse);

      notifier.toggleDarkMode();
      expect(notifier.value.isDarkMode, isTrue);
    });
  });
}

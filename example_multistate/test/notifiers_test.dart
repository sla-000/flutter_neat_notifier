import 'package:flutter_test/flutter_test.dart';
import 'package:example_multistate/notifiers.dart';
import 'package:flutter/material.dart';

void main() {
  group('Notifiers', () {
    test('GIVEN: CounterNotifier, '
        'WHEN: incremented, '
        'THEN: value increases', () {
      final notifier = CounterNotifier();
      notifier.increment();
      expect(notifier.value, 1);
    });

    test('GIVEN: UserNotifier, '
        'WHEN: incrementAge called, '
        'THEN: age increases', () {
      final notifier = UserNotifier();
      notifier.incrementAge();
      expect(notifier.value.age, 26);
    });

    test('GIVEN: ThemeNotifier, '
        'WHEN: toggleTheme called, '
        'THEN: themeMode toggles', () {
      final notifier = ThemeNotifier();
      expect(notifier.value, ThemeMode.light);
      notifier.toggleTheme();
      expect(notifier.value, ThemeMode.dark);
    });
  });
}

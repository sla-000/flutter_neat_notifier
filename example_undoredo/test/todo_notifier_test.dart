import 'package:flutter_test/flutter_test.dart';
import 'package:example_undoredo/todo_notifier.dart';

void main() {
  group('TodoNotifier', () {
    test('GIVEN: TodoNotifier, '
        'WHEN: add is called, '
        'THEN: list contains the new item', () {
      final notifier = TodoNotifier();
      notifier.add('Test');
      expect(notifier.value, ['Test']);
    });

    test('GIVEN: TodoNotifier with items, '
        'WHEN: undo is called, '
        'THEN: state reverts to previous', () {
      final notifier = TodoNotifier();
      notifier.add('Test');
      expect(notifier.value, ['Test']);

      notifier.undo();
      expect(notifier.value, []);
    });
  });
}

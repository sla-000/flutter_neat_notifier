import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestUndoRedoNotifier extends NeatNotifier<int, String>
    with NeatUndoRedoNotifier<int, String> {
  TestUndoRedoNotifier() : super(0);

  void increment() => value++;
  void decrement() => value--;
}

void main() {
  group('NeatUndoRedoNotifier', () {
    test('GIVEN: A notifier with UndoRedo, '
        'WHEN: state changes, '
        'THEN: it can be undone', () {
      final notifier = TestUndoRedoNotifier();
      notifier.increment(); // 1
      notifier.increment(); // 2

      expect(notifier.value, 2);
      expect(notifier.canUndo, true);
      expect(notifier.canRedo, false);

      notifier.undo();
      expect(notifier.value, 1);
      expect(notifier.canUndo, true);
      expect(notifier.canRedo, true);

      notifier.undo();
      expect(notifier.value, 0);
      expect(notifier.canUndo, false);
      expect(notifier.canRedo, true);
    });

    test('GIVEN: A state that was undone, '
        'WHEN: redo is called, '
        'THEN: the state is restored', () {
      final notifier = TestUndoRedoNotifier();
      notifier.increment(); // 1
      notifier.undo(); // 0

      expect(notifier.value, 0);

      notifier.redo();
      expect(notifier.value, 1);
      expect(notifier.canUndo, true);
      expect(notifier.canRedo, false);
    });

    test('GIVEN: A history of changes, '
        'WHEN: a NEW change happens after undo, '
        'THEN: the redo stack is cleared', () {
      final notifier = TestUndoRedoNotifier();
      notifier.increment(); // 1
      notifier.undo(); // 0
      expect(notifier.canRedo, true);

      notifier.decrement(); // -1
      expect(notifier.canRedo, false);

      notifier.undo();
      expect(notifier.value, 0);
    });

    test('GIVEN: maxHistorySize, '
        'WHEN: multiple changes occur, '
        'THEN: only the most recent are kept', () {
      final notifier = TestUndoRedoNotifier()..maxHistorySize = 2;

      notifier.increment(); // 1
      notifier.increment(); // 2
      notifier.increment(); // 3

      expect(notifier.value, 3);

      notifier.undo(); // 2
      notifier.undo(); // 1

      expect(notifier.value, 1);
      expect(notifier.canUndo, false);
    });

    test('GIVEN: clearHistory, '
        'WHEN: called, '
        'THEN: history and redo stacks are emptied', () {
      final notifier = TestUndoRedoNotifier();
      notifier.increment();
      notifier.undo();

      expect(notifier.canUndo, false);
      expect(notifier.canRedo, true);

      notifier.clearHistory();
      expect(notifier.canUndo, false);
      expect(notifier.canRedo, false);
    });
  });
}

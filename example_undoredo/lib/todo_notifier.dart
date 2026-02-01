import 'package:neat_state/neat_state.dart';

class TodoNotifier extends NeatNotifier<List<String>, dynamic>
    with NeatUndoRedoNotifier<List<String>, dynamic> {
  TodoNotifier() : super([]);

  void add(String todo) {
    if (todo.isEmpty) return;
    // We create a NEW list to ensure state immutability.
    // This is crucial for Undo/Redo history to store separate states.
    value = [...value, todo];
  }

  void removeAt(int index) {
    if (index < 0 || index >= value.length) return;
    final newList = [...value];
    newList.removeAt(index);
    value = newList;
  }
}

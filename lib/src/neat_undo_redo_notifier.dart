import 'neat_notifier.dart';

/// A mixin that adds undo/redo (time travel) capabilities to a [NeatNotifier].
mixin NeatUndoRedoNotifier<T, A> on NeatNotifier<T, A> {
  final List<T> _history = [];
  final List<T> _redos = [];

  /// The maximum number of states to keep in history.
  int maxHistorySize = 50;

  bool _isMovingInRange = false;

  @override
  set value(T newValue) {
    if (value == newValue) return;

    if (!_isMovingInRange) {
      _history.add(value);
      _redos.clear();

      if (_history.length > maxHistorySize) {
        _history.removeAt(0);
      }
    }

    super.value = newValue;
  }

  /// Whether there is a previous state to undo to.
  bool get canUndo => _history.isNotEmpty;

  /// Whether there is a next state to redo to.
  bool get canRedo => _redos.isNotEmpty;

  /// Moves back to the previous state in history.
  void undo() {
    if (!canUndo) return;

    final previousState = _history.removeLast();
    _redos.add(value);

    _isMovingInRange = true;
    value = previousState;
    _isMovingInRange = false;
  }

  /// Moves forward to the next state in history.
  void redo() {
    if (!canRedo) return;

    final nextState = _redos.removeLast();
    _history.add(value);

    _isMovingInRange = true;
    value = nextState;
    _isMovingInRange = false;
  }

  /// Clears the history of states.
  void clearHistory() {
    _history.clear();
    _redos.clear();
  }
}

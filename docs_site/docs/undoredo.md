# Undo/Redo

`NeatUndoRedoNotifier` provides a simple way to add history support to your state. It maintains a history stack and a redo stack, allowing you to move backwards and forwards through state changes.

## Usage

1. **Mix in `NeatUndoRedoNotifier`**: Add the mixin to your notifier.
2. **Call `setupUndoRedo()`**: Initialize history in the constructor.
3. **Use `undo()` and `redo()`**: Trigger transitions as needed.
4. **Check `canUndo` and `canRedo`**: Useful for enabling/disabling UI buttons.

```dart
class DrawingNotifier extends NeatNotifier<List<Offset>, void> with NeatUndoRedoNotifier<List<Offset>, void> {
  DrawingNotifier() : super([]) {
    setupUndoRedo(maxHistory: 50);
  }

  void addPoint(Offset point) {
    value = List.from(value)..add(point);
  }
}
```

## Live Example

Draw on the canvas and use the undo/redo buttons in the app bar.

<iframe
  src="https://dartpad.dev/embed-flutter.html?sample_url=https://sla-000.github.io/flutter_neat_notifier/examples/undoredo_example.dart"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>

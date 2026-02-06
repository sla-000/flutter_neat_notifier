
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

## Example

```dart
import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

class DrawingNotifier extends NeatNotifier<List<Offset>, void>
    with NeatUndoRedoNotifier<List<Offset>, void> {
  DrawingNotifier() : super([]) {
    setupUndoRedo();
  }
  void addPoint(Offset point) => value = List.from(value)..add(point);
  void clear() => value = [];
}

void main() => runApp(const MaterialApp(home: UndoRedoDemo()));

class UndoRedoDemo extends StatelessWidget {
  const UndoRedoDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return NeatState(
      create: (_) => DrawingNotifier(),
      builder: (context, points, _) {
        final notifier = context.read<DrawingNotifier>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Undo/Redo Canvas'),
            actions: [
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: notifier.canUndo ? notifier.undo : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: notifier.canRedo ? notifier.redo : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: notifier.clear,
              ),
            ],
          ),
          body: GestureDetector(
            onPanUpdate: (details) => notifier.addPoint(details.localPosition),
            child: CustomPaint(
              painter: SimplePainter(points),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

class SimplePainter extends CustomPainter {
  final List<Offset> points;
  SimplePainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## Next Steps

- [Multiple Providers](07_multi_providers.md)

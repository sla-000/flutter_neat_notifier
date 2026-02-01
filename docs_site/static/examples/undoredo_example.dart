import 'dart:async';
import 'package:flutter/material.dart';

// --- neat_state library start ---
// (Simplified for DartPad)

class NeatNotifier<T, A> extends ValueNotifier<T> {
  NeatNotifier(super.value);
  @override
  set value(T newValue) {
    if (value == newValue) return;
    super.value = newValue;
  }
}

mixin NeatUndoRedoNotifier<T, A> on NeatNotifier<T, A> {
  final List<T> _history = [];
  final List<T> _redoStack = [];
  int _maxHistory = 100;

  void setupUndoRedo({int maxHistory = 100}) {
    _maxHistory = maxHistory;
    _history.add(value);
    addListener(_onStateChanged);
  }

  bool _isInternalChange = false;

  void _onStateChanged() {
    if (_isInternalChange) return;
    _redoStack.clear();
    _history.add(value);
    if (_history.length > _maxHistory) _history.removeAt(0);
  }

  bool get canUndo => _history.length > 1;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    _redoStack.add(_history.removeLast());
    _isInternalChange = true;
    value = _history.last;
    _isInternalChange = false;
  }

  void redo() {
    if (!canRedo) return;
    final next = _redoStack.removeLast();
    _history.add(next);
    _isInternalChange = true;
    value = next;
    _isInternalChange = false;
  }
}

class NeatState<V extends NeatNotifier<S, A>, S, A> extends StatefulWidget {
  const NeatState({super.key, this.create, this.builder});
  final V Function(BuildContext context)? create;
  final Widget Function(BuildContext context, S state, Widget? child)? builder;
  @override
  State<NeatState<V, S, A>> createState() => _NeatState<V, S, A>();
}

class _NeatState<V extends NeatNotifier<S, A>, S, A>
    extends State<NeatState<V, S, A>> {
  V? _notifier;
  @override
  void initState() {
    super.initState();
    _notifier = widget.create!(context);
  }

  @override
  Widget build(BuildContext context) {
    _notifier!.addListener(() => setState(() {}));
    return widget.builder!(context, _notifier!.value, null);
  }
}

// --- App Code ---

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
        final notifier = DrawingNotifier.of(
          context,
        ); // Simplified 'of' for demo
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

// Helper just for this demo code to work in a single block
extension on DrawingNotifier {
  static DrawingNotifier of(BuildContext context) =>
      (context
              .findAncestorStateOfType<
                _NeatState<DrawingNotifier, List<Offset>, void>
              >()!)
          ._notifier!;
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

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

  static V of<V extends NeatNotifier<dynamic, dynamic>>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_NeatInheritedProvider<V>>()!
        .notifier;
  }

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
    _notifier!.addListener(_handleChange);
  }

  void _handleChange() => setState(() {});

  @override
  void dispose() {
    _notifier?.removeListener(_handleChange);
    _notifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NeatInheritedProvider<V>(
      notifier: _notifier!,
      state: _notifier!.value,
      child: Builder(
        builder: (context) {
          return widget.builder!(context, _notifier!.value, null);
        },
      ),
    );
  }
}

class _NeatInheritedProvider<V extends NeatNotifier<dynamic, dynamic>>
    extends InheritedWidget {
  const _NeatInheritedProvider({
    required this.notifier,
    required this.state,
    required super.child,
  });
  final V notifier;
  final dynamic state;
  @override
  bool updateShouldNotify(_NeatInheritedProvider<V> oldWidget) =>
      state != oldWidget.state;
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
      NeatState.of<DrawingNotifier>(context);
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

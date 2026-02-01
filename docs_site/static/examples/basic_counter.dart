import 'dart:async';
import 'package:flutter/material.dart';

// --- neat_state library start ---

typedef NeatLoading = ({bool isUploading, int progress});
typedef NeatError = ({Object error, StackTrace? stackTrace});

class NeatNotifier<T, A> extends ValueNotifier<T> {
  NeatNotifier(super.value);

  @override
  set value(T newValue) {
    if (value == newValue) return;
    super.value = newValue;
  }

  final _actionController = StreamController<A>.broadcast();
  Stream<A> get actions => _actionController.stream;

  NeatError? _error;
  NeatLoading? _loading;

  Object? get error => _error?.error;
  StackTrace? get stackTrace => _error?.stackTrace;
  NeatError? get errorInfo => _error;
  bool get isLoading => _loading != null;
  NeatLoading? get loading => _loading;

  void emitAction(A action) {
    _actionController.add(action);
  }

  @protected
  void setLoading(NeatLoading? value) {
    _updateInternalState(loading: value);
  }

  Future<void> runTask(
    Future<void> Function() task, {
    bool isUploading = false,
  }) async {
    if (isLoading) return;
    _updateInternalState(
      loading: (isUploading: isUploading, progress: 0),
      error: null,
    );
    try {
      await task();
      _updateInternalState(
        loading: (isUploading: isUploading, progress: 100),
        error: null,
      );
    } catch (e, s) {
      _updateInternalState(loading: null, error: (error: e, stackTrace: s));
    } finally {
      if (isLoading) {
        _updateInternalState(loading: null);
      }
    }
  }

  void _updateInternalState({NeatLoading? loading, NeatError? error}) {
    bool changed = false;
    if (_loading != loading) {
      _loading = loading;
      changed = true;
    }
    if (_error != error) {
      _error = error;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _actionController.close();
    super.dispose();
  }
}

class NeatState<V extends NeatNotifier<S, A>, S, A> extends StatefulWidget {
  const NeatState({
    super.key,
    this.create,
    this.builder,
    this.child,
    this.rebuildWhen,
    this.errorBuilder,
    this.loadingBuilder,
    this.onAction,
  });

  final V Function(BuildContext context)? create;
  final Widget Function(BuildContext context, S state, Widget? child)? builder;
  final Widget Function(BuildContext context, NeatError error, Widget? child)?
  errorBuilder;
  final Widget Function(
    BuildContext context,
    NeatLoading loading,
    Widget? child,
  )?
  loadingBuilder;
  final bool Function(S prev, S curr)? rebuildWhen;
  final void Function(BuildContext context, A action)? onAction;
  final Widget? child;

  static V of<V extends NeatNotifier<dynamic, dynamic>>(
    BuildContext context, {
    bool listen = true,
  }) {
    final provider = listen
        ? context
              .dependOnInheritedWidgetOfExactType<_NeatInheritedProvider<V>>()
        : context.getInheritedWidgetOfExactType<_NeatInheritedProvider<V>>();

    if (provider != null) return provider.notifier;

    throw FlutterError(
      'NeatState.of() called with a context that does not contain a $V.',
    );
  }

  @override
  State<NeatState<V, S, A>> createState() => _NeatState<V, S, A>();
}

class _NeatState<V extends NeatNotifier<S, A>, S, A>
    extends State<NeatState<V, S, A>> {
  V? _notifier;
  late S _previousState;
  StreamSubscription<A>? _actionSubscription;
  bool _isOwner = false;

  V get _effectiveNotifier => _notifier!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.create == null && _notifier == null) {
      _initNotifier(NeatState.of<V>(context, listen: false));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.create != null) {
      _isOwner = true;
      _initNotifier(widget.create!(context));
    }
  }

  void _initNotifier(V notifier) {
    _notifier = notifier;
    _previousState = _effectiveNotifier.value;
    _effectiveNotifier.addListener(_handleChange);
    _actionSubscription = _effectiveNotifier.actions.listen((action) {
      if (mounted) {
        widget.onAction?.call(context, action);
      }
    });
  }

  @override
  void dispose() {
    _actionSubscription?.cancel();
    _notifier?.removeListener(_handleChange);
    if (_isOwner) _notifier?.dispose();
    super.dispose();
  }

  void _handleChange() {
    final currentState = _effectiveNotifier.value;
    final shouldRebuild =
        widget.rebuildWhen?.call(_previousState, currentState) ?? true;
    _previousState = currentState;
    if (shouldRebuild ||
        _effectiveNotifier.error != null ||
        _effectiveNotifier.isLoading) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_effectiveNotifier.error != null && widget.errorBuilder != null) {
      content = widget.errorBuilder!(
        context,
        _effectiveNotifier.errorInfo!,
        widget.child,
      );
    } else if (_effectiveNotifier.isLoading && widget.loadingBuilder != null) {
      content = widget.loadingBuilder!(
        context,
        _effectiveNotifier.loading!,
        widget.child,
      );
    } else if (widget.builder != null) {
      content = widget.builder!(
        context,
        _effectiveNotifier.value,
        widget.child,
      );
    } else {
      content = widget.child ?? const SizedBox.shrink();
    }
    return _NeatInheritedProvider<V>(
      notifier: _effectiveNotifier,
      state: _effectiveNotifier.value,
      child: content,
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
      notifier != oldWidget.notifier || state != oldWidget.state;
}

extension NeatContextExtensions on BuildContext {
  V read<V extends NeatNotifier<dynamic, dynamic>>() =>
      NeatState.of<V>(this, listen: false);
  V watch<V extends NeatNotifier<dynamic, dynamic>>() =>
      NeatState.of<V>(this, listen: true);
}

// --- neat_state library end ---

// --- Example App ---

class CounterNotifier extends NeatNotifier<int, String> {
  CounterNotifier() : super(0);

  void increment() {
    value++;
    if (value % 5 == 0) {
      emitAction('Milestone reached: $value!');
    }
  }
}

void main() {
  runApp(const MaterialApp(home: ExamplePage()));
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeatState(
      create: (_) => CounterNotifier(),
      onAction: (context, String action) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(action)));
      },
      builder: (context, count, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('neat_state Counter')),
          body: Center(
            child: Text(
              'Count: $count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<CounterNotifier>().increment(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

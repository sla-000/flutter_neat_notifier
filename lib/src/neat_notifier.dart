import 'dart:async';
import 'package:flutter/widgets.dart';
import 'neat_observer.dart';

typedef NeatLoading = ({bool isUploading, int progress});
typedef NeatError = ({Object error, StackTrace? stackTrace});

/// A [ValueNotifier] that includes error, stack trace, and event information.
///
/// [T] is the type of the state.
/// [A] is the type of actions that can be emitted.
class NeatNotifier<T, A> extends ValueNotifier<T> {
  /// Creates a [NeatNotifier] with an initial value.
  NeatNotifier(super.value);
  @override
  set value(T newValue) {
    if (value == newValue) return;
    super.value = newValue;
    observer?.onStateChange(this, newValue);
  }

  final _actionController = StreamController<A>.broadcast();

  /// A stream of actions emitted by this notifier.
  Stream<A> get actions => _actionController.stream;

  NeatError? _error;
  NeatLoading? _loading;

  /// The current error, if any.
  Object? get error => _error?.error;

  /// The stack trace associated with the [error], if any.
  StackTrace? get stackTrace => _error?.stackTrace;

  /// The current error record, if any.
  NeatError? get errorInfo => _error;

  /// Whether the notifier is currently in a loading state.
  bool get isLoading => _loading != null;

  /// The current loading state, if any.
  NeatLoading? get loading => _loading;

  /// The global observer for all [NeatNotifier] instances.
  static NeatObserver? observer;

  /// A list of interceptors that can transform or block actions.
  ///
  /// Interceptors are called in order. If an interceptor returns `null`,
  /// the action is blocked and further interceptors are not called.
  final List<A? Function(A action)> interceptors = [];

  /// Emits a one-time [action] to all listeners.
  ///
  /// The action first passes through [interceptors]. If any interceptor
  /// returns `null`, the action is blocked. Otherwise, it triggers the
  /// global [observer] and is then added to the [actions] stream.
  void emitAction(A action) {
    A? interceptedAction = action;

    for (final interceptor in interceptors) {
      if (interceptedAction == null) break;
      interceptedAction = interceptor(interceptedAction);
    }

    if (interceptedAction == null) return;

    observer?.onAction(this, interceptedAction);
    _actionController.add(interceptedAction);
  }

  /// Sets the loading state.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void setLoading(NeatLoading? value) {
    _updateInternalState(loading: value);
  }

  /// Runs an asynchronous [task] while automatically managing
  /// [isLoading], [error], and [stackTrace].
  ///
  /// If the notifier is already loading, the task will not be executed.
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

  /// Sets the current error and an optional stack trace.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void setError(Object? error, [StackTrace? stackTrace]) {
    _updateInternalState(
      error: error != null ? (error: error, stackTrace: stackTrace) : null,
    );
  }

  /// Clears the current error and stack trace.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void clearError() {
    _updateInternalState(error: null);
  }

  void _updateInternalState({NeatLoading? loading, NeatError? error}) {
    bool changed = false;

    if (_loading != loading) {
      _loading = loading;
      changed = true;
    }
    if (_error != error) {
      _error = error;
      if (error != null) {
        observer?.onError(this, error.error, error.stackTrace);
      }
      changed = true;
    }

    if (changed) {
      observer?.onStateChange(this, value);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _actionController.close();
    super.dispose();
  }
}

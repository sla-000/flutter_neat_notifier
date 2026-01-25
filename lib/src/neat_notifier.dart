import 'dart:async';
import 'package:flutter/widgets.dart';

/// A [ValueNotifier] that includes error, stack trace, and event information.
///
/// [T] is the type of the state.
/// [E] is the type of events that can be emitted.
class NeatNotifier<T, E> extends ValueNotifier<T> {
  /// Creates a [NeatNotifier] with an initial value.
  NeatNotifier(super.value);

  final _eventController = StreamController<E>.broadcast();

  /// A stream of events emitted by this notifier.
  Stream<E> get events => _eventController.stream;

  Object? _error;
  StackTrace? _stackTrace;
  bool _isLoading = false;

  /// The current error, if any.
  Object? get error => _error;

  /// The stack trace associated with the [error], if any.
  StackTrace? get stackTrace => _stackTrace;

  /// Whether the notifier is currently in a loading state.
  bool get isLoading => _isLoading;

  /// Emits a one-time [event] to all listeners.
  void emitEvent(E event) {
    _eventController.add(event);
  }

  /// Sets the loading state.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void setLoading(bool value) {
    _updateInternalState(isLoading: value);
  }

  /// Runs an asynchronous [task] while automatically managing
  /// [isLoading], [error], and [stackTrace].
  ///
  /// If the notifier is already loading, the task will not be executed.
  Future<void> runTask(Future<void> Function() task) async {
    if (_isLoading) return;

    _updateInternalState(isLoading: true, error: null, stackTrace: null);

    try {
      await task();
    } catch (e, s) {
      _updateInternalState(isLoading: false, error: e, stackTrace: s);
    } finally {
      if (_isLoading) {
        _updateInternalState(isLoading: false);
      }
    }
  }

  /// Sets the current error and an optional stack trace.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void setError(Object? error, [StackTrace? stackTrace]) {
    _updateInternalState(error: error, stackTrace: stackTrace);
  }

  /// Clears the current error and stack trace.
  ///
  /// This will trigger a notification to listeners.
  @protected
  void clearError() {
    _updateInternalState(error: null, stackTrace: null);
  }

  /// Internal helper to update state attributes atomically and notify once.
  void _updateInternalState({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
  }) {
    bool changed = false;
    if (isLoading != null && _isLoading != isLoading) {
      _isLoading = isLoading;
      changed = true;
    }
    if (_error != error) {
      _error = error;
      changed = true;
    }
    if (_stackTrace != stackTrace) {
      _stackTrace = stackTrace;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}

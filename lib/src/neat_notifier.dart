import 'dart:async';
import 'package:flutter/widgets.dart';

typedef NeatLoading = ({bool isUploading, int progress});
typedef NeatError = ({Object error, StackTrace? stackTrace});

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
  NeatLoading? _loading;

  /// The current error, if any.
  Object? get error => _error;

  /// The stack trace associated with the [error], if any.
  StackTrace? get stackTrace => _stackTrace;

  /// Whether the notifier is currently in a loading state.
  bool get isLoading => _loading != null;

  /// The current loading state, if any.
  NeatLoading? get loading => _loading;

  /// Emits a one-time [event] to all listeners.
  void emitEvent(E event) {
    _eventController.add(event);
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
      stackTrace: null,
    );

    try {
      await task();

      _updateInternalState(
        loading: (isUploading: isUploading, progress: 100),
        error: null,
        stackTrace: null,
      );
    } catch (e, s) {
      _updateInternalState(loading: null, error: e, stackTrace: s);
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
    NeatLoading? loading,
    bool isLoading = false, // Kept for partial compatibility if needed
    Object? error,
    StackTrace? stackTrace,
  }) {
    bool changed = false;

    // Use explicit loading record if provided, otherwise fallback to boolean toggle
    final effectiveLoading =
        loading ?? (isLoading ? (isUploading: false, progress: 0) : null);

    if (_loading != effectiveLoading) {
      _loading = effectiveLoading;
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

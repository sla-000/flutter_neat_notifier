import 'package:flutter/widgets.dart';

/// A [ValueNotifier] that includes error and stack trace information.
class ExtValueNotifier<T> extends ValueNotifier<T> {
  /// Creates an [ExtValueNotifier] with an initial value.
  ExtValueNotifier(super.value);

  Object? _error;
  StackTrace? _stackTrace;
  bool _isLoading = false;

  /// The current error, if any.
  Object? get error => _error;

  /// The stack trace associated with the [error], if any.
  StackTrace? get stackTrace => _stackTrace;

  /// Whether the notifier is currently in a loading state.
  bool get isLoading => _isLoading;

  /// Sets the loading state.
  ///
  /// This will trigger a notification to listeners.
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Runs an asynchronous [task] while automatically managing
  /// [isLoading], [error], and [stackTrace].
  ///
  /// If the notifier is already loading, the task will not be executed.
  Future<void> runTask(Future<void> Function() task) async {
    if (_isLoading) return;

    setLoading(true);
    clearError();

    try {
      await task();
    } catch (e, s) {
      setError(e, s);
    } finally {
      setLoading(false);
    }
  }

  /// Sets the current error and an optional stack trace.
  ///
  /// This will trigger a notification to listeners.
  void setError(Object? error, [StackTrace? stackTrace]) {
    _error = error;
    _stackTrace = stackTrace;
    notifyListeners();
  }

  /// Clears the current error and stack trace.
  ///
  /// This will trigger a notification to listeners.
  void clearError() {
    _error = null;
    _stackTrace = null;
    notifyListeners();
  }
}

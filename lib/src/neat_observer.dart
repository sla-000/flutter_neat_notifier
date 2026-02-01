import 'neat_notifier.dart';

/// An interface for observing actions, state changes, and errors
/// across all [NeatNotifier] instances.
abstract class NeatObserver {
  /// Called when an action is emitted by any [NeatNotifier].
  void onAction(NeatNotifier notifier, dynamic action) {}

  /// Called when the state of any [NeatNotifier] changes.
  void onStateChange(NeatNotifier notifier, dynamic state) {}

  /// Called when an error occurs in any [NeatNotifier].
  void onError(NeatNotifier notifier, Object error, StackTrace? stackTrace) {}
}

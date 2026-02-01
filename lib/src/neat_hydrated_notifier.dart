import 'package:neat_notifier/neat_notifier.dart';

/// A mixin that adds persistence to a [NeatNotifier].
///
/// Classes using this mixin must implement [id], [toJson], and [fromJson].
/// The state will be automatically saved to storage whenever it changes,
/// and restored from storage when the notifier is created.
mixin NeatHydratedNotifier<T, A> on NeatNotifier<T, A> {
  /// Unique identifier for this notifier's data in storage.
  String get id;

  /// Restores the state from storage during initialization.
  void hydrate() {
    try {
      final storedData = NeatHydratedStorage.storage.read(id);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restoredState = fromJson(storedData);
        if (restoredState != null) {
          value = restoredState;
        }
      }
    } catch (e) {
      // If hydration fails, we keep the initial value.
      // We could optionally emit an error, but usually initial value is safer.
    }

    // Listen to changes and persist them.
    addListener(_persist);
  }

  void _persist() {
    final json = toJson(value);
    NeatHydratedStorage.storage.write(id, json);
  }

  /// Converts the state to a JSON-encodable map.
  Map<String, dynamic> toJson(T state);

  /// Restores the state from a JSON map.
  T? fromJson(Map<String, dynamic> json);
}

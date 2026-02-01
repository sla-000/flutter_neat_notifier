/// Interface for storage backends used by `NeatHydratedNotifier`.
abstract interface class NeatStorage {
  /// Reads a value from storage for the given [key].
  Object? read(String key);

  /// Writes a value to storage for the given [key].
  Future<void> write(String key, Object? value);

  /// Deletes a value from storage for the given [key].
  Future<void> delete(String key);

  /// Clears all values from storage.
  Future<void> clear();
}

/// A global registry for the storage backend.
class NeatHydratedStorage {
  NeatHydratedStorage._();

  static NeatStorage? _storage;

  /// The current storage backend.
  ///
  /// Must be initialized before using `NeatHydratedNotifier`.
  static NeatStorage get storage {
    if (_storage == null) {
      throw StateError(
        'NeatHydratedStorage.storage is not initialized. '
        'Ensure you call NeatHydratedStorage.initialize() before using hydrated notifiers.',
      );
    }
    return _storage!;
  }

  /// Initializes the storage backend.
  static void initialize(NeatStorage storage) {
    _storage = storage;
  }
}

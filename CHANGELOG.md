## 1.0.0

- Added `context.select` for granular rebuilds using `InheritedModel`.
- Added `NeatHydratedNotifier` and `NeatUndoRedoNotifier` mixins.
- Added record types for loading and error states (`NeatLoading`, `NeatError`).
- Improved `runTask` with tracking for uploading and completion progress.
- Enhanced Dependency Injection with `context.watch<V>()` and `context.read<V>()`.
- Full test coverage for core and examples.
- Professional documentation site with interactive examples.

## 0.1.0

* **Major Refactor**: Builders (`builder`, `onAction`, `errorBuilder`, `loadingBuilder`) now receive state/data directly instead of the notifier instance.
* **Simplified Generics**: `NeatState` now supports zero-parameter type inference when providing the `create` callback.
* **Enhanced Loading**: Introduced `NeatLoading` record with `isUploading` and `progress` fields.
* **Structured Errors**: Introduced `NeatError` record grouping `error` and `stackTrace`.
* **Improved runTask**: Added `isUploading` parameter and automatic 100% progress update on success.
* **DI Enhancements**: Better support for looking up notifiers via `context.watch<V>()` and `context.read<V>()`.

## 0.0.1

* **Initial Release**: Initial release of the package.

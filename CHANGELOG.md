## 0.1.0

* **Major Refactor**: Builders (`builder`, `onEvent`, `errorBuilder`, `loadingBuilder`) now receive state/data directly instead of the notifier instance.
* **Simplified Generics**: `NeatState` now supports zero-parameter type inference when providing the `create` callback.
* **Enhanced Loading**: Introduced `NeatLoading` record with `isUploading` and `progress` fields.
* **Structured Errors**: Introduced `NeatError` record grouping `error` and `stackTrace`.
* **Improved runTask**: Added `isUploading` parameter and automatic 100% progress update on success.
* **DI Enhancements**: Better support for looking up notifiers via `context.watch<V>()` and `context.read<V>()`.

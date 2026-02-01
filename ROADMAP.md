# Roadmap

This file tracks planned features and improvements for `NeatState`. Items will be removed once implemented.

## Planned Features

## Completed Features

- [x] **Undo/Redo (Time Travel)**
  - Optional history management and time travel support via mixin.
  - Configurable `maxHistorySize`.
  - Simple `undo()`, `redo()`, `canUndo`, and `canRedo` APIs.

- [x] **Action Middleware / Interceptors**
  - Global `NeatObserver` for logging, analytics, and error tracking.
  - Local `interceptors` for action transformation and filtering.
  - Mixin-based approach for optional persistence.
  - usage: `class MyNotifier extends NeatNotifier with NeatHydratedNotifier`
  - requires `NeatHydratedStorage.initialize()` before use.

- [x] **Functional Selectors (`context.select`)**
  - Granular rebuilds using `InheritedModel`.
  - Usage: `final count = context.select<CounterNotifier, CounterState, int>((s) => s.count);`

# Roadmap

This file tracks planned features and improvements for `NeatState`. Items will be removed once implemented.

## Planned Features

- [ ] **Undo/Redo (Time Travel)**
  - Optional history management to support "Undo" and "Redo" operations out of the box.
  - Useful for editors and complex forms.

## Completed Features

- [x] **Action Middleware / Interceptors**
  - Global `NeatObserver` for logging, analytics, and error tracking.
  - Local `interceptors` for action transformation and filtering.
  - Mixin-based approach for optional persistence.
  - usage: `class MyNotifier extends NeatNotifier with NeatHydratedNotifier`
  - requires `NeatHydratedStorage.initialize()` before use.

- [x] **Functional Selectors (`context.select`)**
  - Granular rebuilds using `InheritedModel`.
  - Usage: `final count = context.select<CounterNotifier, CounterState, int>((s) => s.count);`

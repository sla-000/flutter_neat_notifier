# Roadmap

This file tracks planned features and improvements for `NeatState`. Items will be removed once implemented.

## Planned Features

- [ ] **Action Middleware / Interceptors**
  - Add support for global or local interceptors to log, transform, or debounce actions.
  - Useful for analytics and debugging.

- [ ] **Undo/Redo (Time Travel)**
  - Optional history management to support "Undo" and "Redo" operations out of the box.
  - Useful for editors and complex forms.

## Completed Features

- [x] **Built-in Persistence (Hydrated State)**
  - Mixin-based approach for optional persistence.
  - usage: `class MyNotifier extends NeatNotifier with NeatHydratedNotifier`
  - requires `NeatHydratedStorage.initialize()` before use.

- [x] **Functional Selectors (`context.select`)**
  - Granular rebuilds using `InheritedModel`.
  - Usage: `final count = context.select<CounterNotifier, CounterState, int>((s) => s.count);`

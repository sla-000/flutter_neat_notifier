# Roadmap

This file tracks planned features and improvements for `NeatState`. Items will be removed once implemented.

## Planned Features

- [ ] **Built-in Persistence (Hydrated State)**
  - Provide a mixin or interface to automatically persist state to local storage.
  - Simplified JSON serialization/deserialization logic.

- [ ] **Action Middleware / Interceptors**
  - Add support for global or local interceptors to log, transform, or debounce actions.
  - Useful for analytics and debugging.

- [ ] **Undo/Redo (Time Travel)**
  - Optional history management to support "Undo" and "Redo" operations out of the box.
  - Useful for editors and complex forms.

## Completed Features

- [x] **Functional Selectors (`context.select`)**
  - Granular rebuilds using `InheritedModel`.
  - Usage: `final count = context.select<CounterNotifier, CounterState, int>((s) => s.count);`

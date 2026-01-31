# Roadmap

This file tracks planned features and improvements for `NeatState`. Items will be removed once implemented.

## Planned Features

- [ ] **Functional Selectors (`context.select`)**
  - Allow fine-grained rebuilds in `StatelessWidgets` using a selector pattern.
  - Example: `final count = context.select<CounterNotifier, int>((s) => s.count);`

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
*(Items move here after implementation)*

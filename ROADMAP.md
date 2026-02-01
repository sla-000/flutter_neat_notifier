# Project Roadmap

## Planned Features

- [ ] **NeatMultiProvider (Avoid Nesting Hell)**
  - Implement `NeatMultiProvider` to allow linear declaration of providers and avoid deep nesting.
  - Simplify dependency injection between notifiers.

- [ ] **Type Ergonomics**
  - Improve type inference for selectors.
  - Goal: Allow `context.select<MyNotifier, int>((s) => s.count)` without explicitly specifying the State type.

- [ ] **DevTools Extension**
  - Build a plugin for Flutter DevTools.
  - Visualize the Neat State tree, action history, and notifier states.

- [ ] **Code Generation**
  - Explore Dart Macros or `build_runner` to reduce boilerplate.
  - Auto-generate `copyWith` and `toJson`/`fromJson` methods for state records.

## Completed Features

- [x] **Undo/Redo (Time Travel)**
  - Optional history management and time travel support via mixin.
  - Configurable `maxHistorySize`.
  - Simple `undo()`, `redo()`, `canUndo`, and `canRedo` APIs.

- [x] **Action Middleware / Interceptors**
  - Global `NeatObserver` for logging, analytics, and error tracking.
  - Local `interceptors` for action transformation and filtering.

- [x] **Built-in Persistence (Hydrated State)**
  - Mixin-based approach for optional persistence.
  - usage: `class MyNotifier extends NeatNotifier with NeatHydratedNotifier`
  - requires `NeatHydratedStorage.initialize()` before use.

- [x] **Functional Selectors**
  - `context.select<Notifier, State, Result>((state) => state.property)`
  - Granular rebuilds for performance optimization.

- [x] **Simplified API**
  - Removed `NeatState` class boilerplate (type inference).
  - Added specific types for `NeatLoading` and `NeatError`.

- [x] **Game Animations**
  - Word Intro/Outro animations.
  - Play button scale animation.

- [x] **Menu Animations**
  - Staggered entry animations for stars and buttons.
  - Star selection scale effect.

- [x] **Background Effects**
  - Color-shifting background.
  - Pulsing/Scaling background elements.

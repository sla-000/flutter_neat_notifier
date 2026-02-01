# neat_state

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Coverage Status](https://coveralls.io/repos/github/sla-000/flutter_neat_notifier/badge.svg?branch=main)](https://coveralls.io/github/sla-000/flutter_neat_notifier?branch=main)
[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg)](https://sla-000.github.io/flutter_neat_notifier/)

A lightweight, feature-rich state management package for Flutter that builds upon `ValueNotifier` to provide a robust solution for handling states, one-time actions, and asynchronous operations with built-in loading and error management.

## Features

- **Extends ValueNotifier**: Leverages the familiar and performant `ValueNotifier` API.
- **Built-in Async Support**: Easily manage `isLoading`, `error`, and `stackTrace` with the `runTask` method.
- **Action System**: Emit and listen to one-time actions (e.g., showing a SnackBar or navigation) outside the main state.
- **Enhanced Rebuilds**: Uses `InheritedModel` for granular rebuilds via `context.select`.
- **State Persistence**: Built-in support for hydrated state via `NeatHydratedNotifier`.
- **Undo/Redo Support**: Easily add history points with `NeatUndoRedoNotifier`.
- **Dedicated Builders**: Specific builders for `loading` and `error` states to keep your UI code clean.

## Documentation

For detailed guides and interactive examples, visit our [documentation site](https://sla-000.github.io/flutter_neat_notifier/).

## Getting started

Add `neat_state` to your `pubspec.yaml`:

```yaml
dependencies:
  neat_state: ^0.0.1
```

Then run:
```bash
flutter pub get
```

### Simple Counter Example

If you don't need actions or complex state, just use primitives:

```dart
class Counter extends NeatNotifier<int, void> {
  Counter() : super(0);
  void increment() => value++;
}

// Usage
NeatState(
  create: (_) => Counter(),
  builder: (context, count, _) => Text('Count: $count'),
)
```

### Advanced Usage

For more complex scenarios involving records, async tasks, and actions:

```dart
typedef CounterState = ({int count});

sealed class CounterAction {}
class Milestone extends CounterAction {
  final String message;
  Milestone(this.message);
}

class AdvancedCounter extends NeatNotifier<CounterState, CounterAction> {
  AdvancedCounter() : super((count: 0));

  Future<void> increment() => runTask(() async {
    await Future.delayed(const Duration(seconds: 1));
    value = (count: value.count + 1);
    
    if (value.count % 5 == 0) {
      emitAction(Milestone('Reached ${value.count}!'));
    }
  });
}
```

```dart
NeatState(
  create: (context) => AdvancedCounter(),
  onAction: (context, action) {
    if (action is Milestone) /* Show SnackBar */ ...
  },
  loadingBuilder: (context, loading, _) => CircularProgressIndicator(),
  builder: (context, state, _) => Text('Count: ${state.count}'),
)
```

## Example Gallery

Explore specific capabilities through our dedicated examples:

- 🚀 [**Basic Counter**](example/) - Getting started with simple types.
- ⏳ [**Async Tasks**](example_runtask/) - Deep-dive into `runTask` and progress management.
- 📦 [**Multi-State**](example_multistate/) - Using `NeatMultiState` to manage multiple notifiers.
- 💾 [**Hydrated State**](example_hydrated/) - Easy persistence using `NeatHydratedNotifier`.
- 🔄 [**Undo/Redo**](example_undoredo/) - Adding history support with `NeatUndoRedoNotifier`.
- 🛠️ [**Advanced Patterns**](example_advanced/) - Selectors, Observers, and custom storage.

## Context Extensions

`neat_state` provides convenient extension methods on `BuildContext` for easy access to your notifiers:

- **`context.read<V>()`**: Gets the notifier without listening. Best for calling methods (e.g., in `onPressed`).
- **`context.watch<V>()`**: Gets the notifier and listens for any changes.
- **`context.select<V, S, R>((state) => ...)`**: Listens only to a specific part of the state.

```dart
// 1. Just call a method
onPressed: () => context.read<CounterNotifier>().increment(),

// 2. Rebuild whenever anything changes
final count = context.watch<CounterNotifier>().value;

// 3. Rebuild ONLY when a specific field changes
final userName = context.select<UserNotifier, UserState, String>(
  (state) => state.name,
);
```

## Features Deep Dive

- **Enhanced Loading**: `NeatLoading` record provides `isUploading` and `progress`.
- **Structured Errors**: `NeatError` record groups `error` and `stackTrace`.
- **Direct State Access**: Builders receive the state/data directly for cleaner code.
- **Smart Inference**: Zero-parameter shorthand for `NeatState`.

## Additional information

For a detailed look at the core principles and architectural constraints of this project, please refer to the [RULES.md](RULES.md) file.

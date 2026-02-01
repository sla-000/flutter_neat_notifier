---
sidebar_position: 1
---

# Introduction

**neat_state** is a lightweight, feature-rich state management package for Flutter that builds upon `ValueNotifier` to provide a robust solution for handling states, one-time actions, and asynchronous operations with built-in loading and error management.

## Why neat_state?

- **Zero Boilerplate**: No need to create separate classes for events or state if you don't want to.
- **Familiar API**: If you know `ValueNotifier`, you know `neat_state`.
- **Built-in Async**: Native support for loading states and error handling.
- **One-time Actions**: Perfect for snackbars, navigation, or dialogs.
- **Granular Rebuilds**: Optimized with `InheritedModel` and `context.select`.

## Live Demo

Here is a simple counter example working live.

<iframe
  src="https://dartpad.dev/embed-flutter.html?id=3a160a928c3c9ad0ff86292feabd3b5d"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>



## Installation

Add `neat_state` to your `pubspec.yaml`:

```yaml
dependencies:
  neat_state: ^2.0.0
```

Or run:

```bash
flutter pub add neat_state
```


## Next Steps

- [Hydrated Notifiers](hydrated.md)
- [Undo/Redo](undoredo.md)
- [Async Operations](async_operations.md)
- [Multi-State Management](multi_state.md)
- [Context Extensions](context_extensions.md)

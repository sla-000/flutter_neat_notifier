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

## Example

Here is a simple counter example:

```dart
import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

void main() {
  runApp(const MaterialApp(home: SimpleExamplePage()));
}

// 1. Create a notifier
class CounterNotifier extends NeatNotifier<int, void> {
  CounterNotifier() : super(0);

  void increment() => value++;
}

class SimpleExamplePage extends StatelessWidget {
  const SimpleExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Use it in your UI
    return NeatState<CounterNotifier, int, void>(
      create: (_) => CounterNotifier(),
      builder: (context, count, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Simple Example')),
          body: Center(
            child: Text(
              'Count: $count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<CounterNotifier>().increment(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
```



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
- [Advanced Usage](advanced.md)

---
sidebar_position: 3
---

# Reading State

`neat_state` provides a set of powerful extensions on `BuildContext` to interact with your notifiers. These extensions make it easy to access state, listen for changes, and select specific parts of the state to optimize rebuilds.

## `context.read<T>`

Obtains the notifier of type `T` from the nearest ancestor `NeatState` or `NeatMultiState`.

- **Usage**: Use this when you need to call a method on the notifier (like an event handler) or access its value without triggering a rebuild.
- **Common Use Case**: `onPressed` callbacks, `initState` logic.

```dart
ElevatedButton(
  // Does not rebuild when CounterNotifier changes
  onPressed: () => context.read<CounterNotifier>().increment(),
  child: const Text('Increment'),
),
```

## `context.watch<T>`

Obtains the notifier of type `T` and subscribes the widget to changes.

- **Usage**: Use this when your widget needs to rebuild every time the notifier's value changes.
- **Common Use Case**: Building UI that depends on the entire state.

```dart
@override
Widget build(BuildContext context) {
  // Rebuilds whenever ThemeNotifier changes
  final themeMode = context.watch<ThemeNotifier>().value;
  
  return MaterialApp(
    themeMode: themeMode,
    // ...
  );
}
```

## `context.select<T, R>`

Listens to a specific part of the state.

- **Usage**: Use this to optimize performance by only rebuilding when a specific property of the state changes.
- **Parameters**: 
  - `T`: The type of the Notifier.
  - `R`: The type of the selected value.
  - `selector`: A function that maps the state (or notifier) to the value you want to listen to.

```dart
@override
Widget build(BuildContext context) {
  // Only rebuild if the user's name changes, ignore age or other property changes
  final name = context.select<UserNotifier, User, String>((user) => user.name);

  return Text('Name: $name');
}
```

:::tip
`context.select` is powered by `InheritedModel`, ensuring efficient updates only when necessary.
:::

## Example

```dart
import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

void main() {
  runApp(const MyApp());
}

// --- Simple Notifier ---
class CounterNotifier extends NeatNotifier<int, void> {
  CounterNotifier() : super(0);

  void increment() => value++;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeatState<CounterNotifier, int, void>(
      create: (_) => CounterNotifier(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. context.watch: Rebuilds whenever state changes
    final count = context.watch<CounterNotifier>().value;

    return Scaffold(
      appBar: AppBar(title: const Text('Context Extensions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Context.watch:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('$count', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 32),
            const SelectorExample(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 2. context.read: Access notifier without rebuilding
        onPressed: () => context.read<CounterNotifier>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SelectorExample extends StatelessWidget {
  const SelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. context.select: Only rebuilds when the selected value changes
    final isGreaterThanFive = context.select<CounterNotifier, int, bool>(
      (count) => count > 5,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: isGreaterThanFive ? Colors.green.shade100 : Colors.grey.shade200,
      child: Text(
        isGreaterThanFive ? '> 5' : '<= 5',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
```

## Next Steps

- [Side Effects & Listeners](04_listeners.md)



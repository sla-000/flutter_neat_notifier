import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

void main() {
  runApp(const MyApp());
}

/// A simple notifier that manages an integer count.
///
/// It extends [NeatNotifier] with:
/// - State type: `int`
/// - Action type: `void` (no side-effect actions needed for this simple example)
class CounterNotifier extends NeatNotifier<int, void> {
  // Initialize with 0
  CounterNotifier() : super(0);

  void increment() {
    value++;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the Notifier
    return NeatState(
      create: (_) => CounterNotifier(),
      child: const MaterialApp(home: CounterPage()),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Access the Notifier
    // 'watch' listens for changes and rebuilds this widget when 'value' updates.
    final counter = context.watch<CounterNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('NeatNotifier Basic Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            // Display the current value
            Text(
              '${counter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 3. Update the state
        // We can call methods directly on the notifier instance.
        onPressed: counter.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

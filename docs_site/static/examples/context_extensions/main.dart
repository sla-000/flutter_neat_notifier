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
    // Here we check if the count is even. This widget ONLY rebuilds when
    // even/odd status flips, not on every increment (though parity flips on every increment, concept holds).
    // Let's pretend we only care if it's > 5
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

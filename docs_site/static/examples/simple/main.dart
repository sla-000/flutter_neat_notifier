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

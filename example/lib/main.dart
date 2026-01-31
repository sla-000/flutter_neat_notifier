import 'package:neat_notifier/neat_notifier.dart';
import 'package:flutter/material.dart';

import 'counter_notifier.dart';
import 'settings_notifier.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Acts as a Provider for the whole app
    return NeatState<SettingsNotifier, SettingsState, SettingsEvent>(
      create: (context) => SettingsNotifier(),
      builder: (context, state, child) {
        return MaterialApp(
          title: 'NeatNotifier Example',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'NeatNotifier DI Demo'),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // 2. Acts as a Provider for this screen
    return NeatState<CounterNotifier, CounterState, CounterEvent>(
      create: (context) => CounterNotifier(),
      onEvent: (context, event) => _showSnackbar(event, context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
          actions: [
            // 3. Simple Consumer using context.watch
            Builder(
              builder: (context) {
                final settings = context.watch<SettingsNotifier>();
                return IconButton(
                  icon: Icon(
                    settings.value.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: settings.toggleDarkMode,
                );
              },
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CounterDisplay(),
              SizedBox(height: 32),
              CounterActions(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(CounterEvent event, BuildContext context) {
    final message = switch (event) {
      CounterMilestoneEvent(message: final m) => m,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.deepPurple),
    );
  }
}

/// A deep child that consumes the CounterNotifier via DI
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Acts as a Consumer (no 'create' needed)
    return NeatState<CounterNotifier, CounterState, CounterEvent>(
      rebuildWhen: (prev, curr) =>
          prev.counter1 != curr.counter1 || prev.counter2 != curr.counter2,
      errorBuilder: (context, error, stackTrace, child) =>
          Text('Error: $error', style: const TextStyle(color: Colors.red)),
      loadingBuilder: (context, state, child) =>
          const CircularProgressIndicator(),
      builder: (context, state, child) {
        return Column(
          children: [
            const Text('Counter 1 (Async + Error prone):'),
            Text(
              '${state.counter1}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text('Counter 2:'),
            Text(
              '${state.counter2}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text('Counter 3:'),
            Text(
              '${state.counter3}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        );
      },
    );
  }
}

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Using context.read for actions (no rebuild needed)
    final notifier = context.read<CounterNotifier>();
    final isLoading = context.watch<CounterNotifier>().isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'btn1',
          onPressed: isLoading ? null : notifier.increment1,
          tooltip: 'Increment Counter 1 (Async)',
          child: const Text('1'),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: 'btn2',
          onPressed: notifier.increment2,
          tooltip: 'Increment Counter 2',
          backgroundColor: Colors.grey,
          child: const Text('2'),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: 'btn3',
          onPressed: notifier.increment3,
          tooltip: 'Increment Counter 3',
          backgroundColor: Colors.blueGrey,
          child: const Text('3'),
        ),
      ],
    );
  }
}

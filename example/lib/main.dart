import 'package:neat_notifier/neat_notifier.dart';
import 'package:flutter/material.dart';

import 'counter_notifier.dart';
import 'theme_notifier.dart';
import 'simple_storage.dart';
import 'logger_observer.dart';

void main() async {
  // 1. Initialize storage before using hydrated notifiers
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SimpleStorage();
  await storage.init();
  NeatHydratedStorage.initialize(storage);

  // 2. Add global observer for logging/analytics
  NeatNotifier.observer = LoggerObserver();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Hydrated Notifier handles persistence automatically
    return NeatState(
      create: (context) => ThemeNotifier(),
      builder: (context, bool isDarkMode, child) {
        return MaterialApp(
          title: 'NeatState Example',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'NeatState Demo'),
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
    return NeatState(
      create: (context) => CounterNotifier(),
      onAction: (context, CounterAction action) =>
          _showSnackbar(context, action),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
          actions: [
            // 3. Simple Consumer using context.watch
            Builder(
              builder: (context) {
                final isDarkMode = context.watch<ThemeNotifier>().value;
                return IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: context.read<ThemeNotifier>().toggle,
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

  void _showSnackbar(BuildContext context, CounterAction action) {
    final message = switch (action) {
      CounterMilestoneAction(message: final m) => m,
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
    return NeatState<CounterNotifier, CounterState, CounterAction>(
      rebuildWhen: (prev, curr) =>
          prev.counter1 != curr.counter1 || prev.counter2 != curr.counter2,
      errorBuilder: (context, error, child) => Text(
        'Error: ${error.error}',
        style: const TextStyle(color: Colors.red),
      ),
      loadingBuilder: (context, loading, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loading.isUploading ? 'Uploading...' : 'Loading...'),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: loading.progress > 0 ? loading.progress / 100 : null,
            ),
          ),
        ],
      ),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: NeatState.of<CounterNotifier>(context),
                  builder: (context, state, _) {
                    final notifier = NeatState.of<CounterNotifier>(
                      context,
                      listen: false,
                    );
                    return IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: notifier.canUndo ? notifier.undo : null,
                      tooltip: 'Undo',
                    );
                  },
                ),
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: NeatState.of<CounterNotifier>(context),
                  builder: (context, state, _) {
                    final notifier = NeatState.of<CounterNotifier>(
                      context,
                      listen: false,
                    );
                    return IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed: notifier.canRedo ? notifier.redo : null,
                      tooltip: 'Redo',
                    );
                  },
                ),
              ],
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
    final isLoading = context.select<CounterNotifier, CounterState, bool>(
      (s) => notifier.isLoading,
    );

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

import 'package:neat_state/neat_state.dart';
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
    // 3. Use NeatMultiState to provide multiple notifiers
    return NeatMultiState(
      independent: [(_) => ThemeNotifier(), (_) => CounterNotifier()],
      child: Builder(
        builder: (context) {
          // 4. Listen to the theme state
          final isDarkMode = context.select<ThemeNotifier, bool, bool>(
            (state) => state,
          );

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
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: context.read<ThemeNotifier>().toggle,
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CounterDisplay(), SizedBox(height: 32), CounterActions()],
        ),
      ),
    );
  }
}

/// A deep child that consumes the CounterNotifier via DI
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Acts as a Consumer (no 'create' needed)
    return NeatState<CounterNotifier, CounterState, CounterAction>(
      onAction: (context, action) {
        if (action is CounterMilestoneAction) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(action.message)));
        }
      },
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
    // 6. Using context.read for actions (no rebuild needed)
    final notifier = context.read<CounterNotifier>();

    // We can select specific properties to listen to,
    // but here we just want to know if it's loading to disable button
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

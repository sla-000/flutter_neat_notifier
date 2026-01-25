import 'package:ext_notifier/ext_notifier.dart';
import 'package:flutter/material.dart';

import 'counter_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExtValueBuilder Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ExtValueBuilder Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ExtValueBuilder<CounterValueNotifier, CounterState, CounterEvent>(
      create: (context) => CounterValueNotifier(),
      onEvent: (context, notifier, event) {
        final message = switch (event) {
          CounterMilestoneEvent(message: final m) => m,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.deepPurple),
        );
      },
      rebuildWhen: (prev, curr) =>
          prev.counter1 != curr.counter1 || prev.counter2 != curr.counter2,
      errorBuilder: (context, error, stackTrace, notifier) =>
          AppErrorWidget(error: error, onRetry: notifier.increment1),
      loadingBuilder: (context, notifier) => const AppLoadingWidget(),
      builder: (context, notifier, child) {
        final state = notifier.value;
        // This print helps demonstrate when the widget rebuilds
        debugPrint(
          'Building MyHomePage: counter1=${state.counter1}, counter2=${state.counter2}, counter3=${state.counter3}',
        );

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Optimization Rule:\nRebuilds if EITHER Counter 1 OR Counter 2 change.\n(Counter 3 changes are ignored)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (child case final child?) ...[
                  const SizedBox(height: 32),
                  child,
                ],
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'btn1',
                onPressed: notifier.isLoading ? null : notifier.increment1,
                tooltip: 'Increment Counter 1 (Async)',
                child: const Icon(Icons.cloud_upload),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'btn2',
                onPressed: notifier.increment2,
                tooltip: 'Increment Counter 2',
                backgroundColor: Colors.grey,
                child: const Icon(Icons.exposure_plus_2),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'btn3',
                onPressed: notifier.increment3,
                tooltip: 'Increment Counter 3',
                backgroundColor: Colors.blueGrey,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
      child: const HeavyWidgetThatWeDoNotWantToRebuild(),
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Something went wrong:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class HeavyWidgetThatWeDoNotWantToRebuild extends StatelessWidget {
  const HeavyWidgetThatWeDoNotWantToRebuild({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building HeavyWidgetThatWeDoNotWantToRebuild');
    return const Text('Widget not affected by the Notifier');
  }
}

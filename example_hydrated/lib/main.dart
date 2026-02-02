import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';
import 'simple_storage.dart';
import 'theme_notifier.dart';
import 'counter_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize custom storage
  final storage = SimpleStorage();
  await storage.init();

  // 2. Set the global hydrated storage
  NeatHydratedStorage.initialize(storage);

  runApp(const HydratedApp());
}

class HydratedApp extends StatelessWidget {
  const HydratedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Provide multiple hydrated notifiers
    return NeatMultiState(
      independent: [(_) => ThemeNotifier(), (_) => CounterNotifier()],
      child: Builder(
        builder: (context) {
          // 4. Listen to theme state for dynamic styling
          final isDarkMode = context.select<ThemeNotifier>()((state) => state);

          return MaterialApp(
            title: 'Neat Hydrated Example',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const MyHomePage(title: 'Neat Hydrated Demo'),
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
          // 5. Toggle theme persistence
          IconButton(
            icon: Icon(
              context.watch<ThemeNotifier>().value
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeNotifier>().toggle(),
            tooltip: 'Toggle Theme Persistence',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This counter survives app restarts:'),
            // 6. Use NeatState to listen to counter
            NeatState<CounterNotifier, int, void>(
              builder: (context, state, child) {
                return Text(
                  '$state',
                  style: Theme.of(context).textTheme.headlineLarge,
                );
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Try incrementing the counter or changing themes, '
                'then stop and restart the app to see it persisted!',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterNotifier>().increment(),
        tooltip: 'Increment and Persist',
        child: const Icon(Icons.add),
      ),
    );
  }
}

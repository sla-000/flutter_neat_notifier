import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';
import 'notifiers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeatMultiState(
      independent: [
        (_) => CounterNotifier(),
        (_) => UserNotifier(),
        (_) => ThemeNotifier(),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeNotifier>().value;
          return MaterialApp(
            title: 'Neat Multi-State Example',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neat Multi-State'),
        actions: [
          IconButton(
            icon: context.watch<ThemeNotifier>().value == ThemeMode.light
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CounterCard(),
            const SizedBox(height: 16),
            const UserCard(),
          ],
        ),
      ),
    );
  }
}

class CounterCard extends StatelessWidget {
  const CounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeatState<CounterNotifier, int, String>(
      onAction: (context, action) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(action)));
      },
      builder: (context, count, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Counter Notifier', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text('Count: $count', style: const TextStyle(fontSize: 32)),
                ElevatedButton(
                  onPressed: () => context.read<CounterNotifier>().increment(),
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Using select for granular rebuilds
    final name = context.select<UserNotifier>()((u) => u.name);
    final age = context.select<UserNotifier>()((u) => u.age);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('User Notifier', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Name: $name', style: const TextStyle(fontSize: 18)),
            Text('Age: $age', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<UserNotifier>().updateName(
                    'User ${DateTime.now().second}',
                  ),
                  child: const Text('Update Name'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<UserNotifier>().incrementAge(),
                  child: const Text('Increment Age'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

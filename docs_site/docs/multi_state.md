# Multi-State Management

For applications with multiple notifiers, `NeatMultiState` helps you inject dependencies high up in the widget tree, making them accessible to all descendants.

## `NeatMultiState`

This widget avoids the "pyramid of doom" (nested builders) when you have multiple providers. It supports both independent notifiers and dependent "providers" (like `NeatState` widgets).

### Usage

```dart
NeatMultiState(
  // 1. Independent Notifiers
  // Notifiers that don't depend on others.
  independent: [
    (_) => CounterNotifier(),
    (_) => ThemeNotifier(),
  ],
  
  // 2. Dependent Providers
  // Function builders that can nest other providers or depend on independent ones.
  // These are built in order, so later items can depend on earlier ones.
  providers: [
    (child) => NeatState<UserNotifier, User, void>(
          create: (_) => UserNotifier(),
          builder: (context, user, _) => child,
        ),
    (child) => ProxyProvider0<AuthService>( // Example of interop
          update: (_, __) => AuthService(),
          child: child,
        ),
  ],
  
  child: MyApp(),
)
```

## Accessing State

To access the state efficiently, use the provided context extensions. 
See the [Context Extensions](context_extensions.md) page for detailed usage of `context.read`, `context.watch`, and `context.select`.

## Example

```dart
import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

void main() {
  runApp(const MyApp());
}

// --- Notifiers ---

class ThemeNotifier extends NeatNotifier<ThemeMode, void> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class CounterNotifier extends NeatNotifier<int, String> {
  CounterNotifier() : super(0);

  void increment() {
    value++;
    if (value % 5 == 0) {
      sendAction('Reached $value!');
    }
  }
}

class UserNotifier extends NeatNotifier<User, void> {
  UserNotifier() : super(User(name: 'Guest', age: 25));

  void updateName(String name) {
    value = value.copyWith(name: name);
  }

  void incrementAge() {
    value = value.copyWith(age: value.age + 1);
  }
}

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  User copyWith({String? name, int? age}) {
    return User(name: name ?? this.name, age: age ?? this.age);
  }
}

// --- App ---

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
            theme: ThemeData(useMaterial3: true),
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
    final name = context.select<UserNotifier, User, String>((u) => u.name);
    final age = context.select<UserNotifier, User, int>((u) => u.age);

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
```

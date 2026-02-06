
# Persisting State

`NeatHydratedNotifier` adds automatic persistence to your notifiers. It saves the state to disk whenever it changes and restores it when the notifier is initialized.

## Usage

1. **Initialize Storage**: Call `NeatHydratedStorage.initialize()` before `runApp`.
2. **Mix in `NeatHydratedNotifier`**: Add the mixin to your notifier.
3. **Implement `id`, `fromJson`, and `toJson`**: These are required for identification and serialization.
4. **Call `hydrate()`**: Call this in the constructor to load the saved state.

```dart
class SettingsNotifier extends NeatNotifier<ThemeMode, void> with NeatHydratedNotifier<ThemeMode, void> {
  SettingsNotifier() : super(ThemeMode.system) {
    hydrate();
  }

  @override
  String get id => 'settings_persistence';

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) => ThemeMode.values[json['theme'] as int];

  @override
  Map<String, dynamic> toJson(ThemeMode state) => {'theme': state.index};
}
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

class SettingsNotifier extends NeatNotifier<ThemeMode, void>
    with NeatHydratedNotifier<ThemeMode, void> {
  SettingsNotifier() : super(ThemeMode.system) {
    hydrate();
  }
  @override
  String get id => 'settings';
  void toggle() =>
      value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values[json['theme'] as int];
  @override
  Map<String, dynamic> toJson(ThemeMode state) => {'theme': state.index};
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NeatHydratedStorage.initialize(); // Uses default Hive storage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return NeatState(
      create: (_) => SettingsNotifier(),
      builder: (context, mode, _) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Hydrated State Demo')),
            body: Center(child: Text('Current Mode: $mode')),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<SettingsNotifier>().toggle(),
              child: const Icon(Icons.brightness_4),
            ),
          ),
        );
      },
    );
  }
}
```

:::tip
In a real application, you would use a persistent storage like `shared_preferences` or `hive`. See the [Advanced Patterns](https://github.com/sla-000/flutter_neat_notifier/tree/main/example_advanced) folder for a storage implementation using `path_provider`.
:::

## Next Steps

- [Undo/Redo](06_undo_redo.md)

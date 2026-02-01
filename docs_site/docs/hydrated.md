# Hydrated State

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

## Live Example

Try toggling the theme and refreshing the page (simulated via the "Run" button in DartPad).

<iframe
  src="https://dartpad.dev/embed-flutter.html?sample_url=https://raw.githubusercontent.com/sla-000/flutter_neat_notifier/main/docs_site/static/examples/hydrated/main.dart"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>

:::tip
In a real application, you would use a persistent storage like `shared_preferences` or `hive`. See the [Advanced Patterns](https://github.com/sla-000/flutter_neat_notifier/tree/main/example_advanced) folder for a storage implementation using `path_provider`.
:::

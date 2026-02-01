# Context Extensions

`neat_state` provides a set of powerful extensions on `BuildContext` to interact with your notifiers. These extensions make it easy to access state, listen for changes, and select specific parts of the state to optimize rebuilds.

## `context.read<T>`

Obtains the notifier of type `T` from the nearest ancestor `NeatState` or `NeatMultiState`.

- **Usage**: Use this when you need to call a method on the notifier (like an event handler) or access its value without triggering a rebuild.
- **Common Use Case**: `onPressed` callbacks, `initState` logic.

```dart
ElevatedButton(
  // Does not rebuild when CounterNotifier changes
  onPressed: () => context.read<CounterNotifier>().increment(),
  child: const Text('Increment'),
),
```

## `context.watch<T>`

Obtains the notifier of type `T` and subscribes the widget to changes.

- **Usage**: Use this when your widget needs to rebuild every time the notifier's value changes.
- **Common Use Case**: Building UI that depends on the entire state.

```dart
@override
Widget build(BuildContext context) {
  // Rebuilds whenever ThemeNotifier changes
  final themeMode = context.watch<ThemeNotifier>().value;
  
  return MaterialApp(
    themeMode: themeMode,
    // ...
  );
}
```

## `context.select<T, R>`

Listens to a specific part of the state.

- **Usage**: Use this to optimize performance by only rebuilding when a specific property of the state changes.
- **Parameters**: 
  - `T`: The type of the Notifier.
  - `R`: The type of the selected value.
  - `selector`: A function that maps the state (or notifier) to the value you want to listen to.

```dart
@override
Widget build(BuildContext context) {
  // Only rebuild if the user's name changes, ignore age or other property changes
  final name = context.select<UserNotifier, User, String>((user) => user.name);

  return Text('Name: $name');
}
```

:::tip
`context.select` is powered by `InheritedModel`, ensuring efficient updates only when necessary.
:::

## Live Example

<iframe
  src="https://dartpad.dev/embed-flutter.html?id=ID_GOES_HERE"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>


---
sidebar_position: 4
---

# Side Effects & Listeners

State management isn't just about rebuilding UI. Sometimes you need to perform actions *once* when a state changes, such as showing a Snackbar, navigating to a new screen, or displaying a dialog.

`neat_state` handles this elegantly via the `listener` callback in the `NeatState` widget.

## The `listener` Callback

The `NeatState` widget provides a `listener` parameter that is called whenever the notifier emits a new value. This callback is run **after** the build phase, making it safe to trigger side effects like navigation or showing overlays.

### API Breakdown

```dart
NeatState<MyNotifier, StateType, EventType>(
  create: (_) => MyNotifier(),
  listener: (context, state) {
    // Check state and trigger side effects
  },
  builder: (context, state, child) {
    return MyWidget();
  },
)
```

## Common Use Cases

### 1. Showing a Snackbar on Error

You can listen for specific state conditions to show feedback to the user.

```dart
listener: (context, state) {
  if (state == MyState.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Something went wrong!')),
    );
  }
},
```

### 2. Navigation on Success

Navigate to a different screen when an operation completes successfully.

```dart
listener: (context, state) {
  if (state == MyState.success) {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }
},
```

### 3. Displaying Dialogs

Show a dialog when a specific event occurs.

```dart
listener: (context, state) {
  if (state.requiresConfirmation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure?'),
      ),
    );
  }
},
```

## Best Practices

- **Keep it Logic-Free**: Try to keep business logic inside your Notifier. Use the listener primarily for UI-related side effects.
- **Context Usage**: The `listener` callback provides a valid `BuildContext`, so you don't need to look it up manually.

## Next Steps

- [Persisting State](05_persistence.md) 

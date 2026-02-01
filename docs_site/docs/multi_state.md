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

## Live Example

Here is an example showing multiple notifiers (Counter, Theme, User) working together.

<iframe
  src="https://dartpad.dev/embed-flutter.html?id=ID_GOES_HERE"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>

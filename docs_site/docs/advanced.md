---
sidebar_position: 6
---

# Advanced Usage

This page covers advanced features of `neat_state` for global observability and action interception.

## NeatObserver

`NeatObserver` allows you to listen to events across **all** `NeatNotifier` instances in your app. This is useful for logging, analytics, or debugging.

To use it, implement the `NeatObserver` interface and assign it to `NeatNotifier.observer`.

```dart
class MyLogger extends NeatObserver {
  @override
  void onAction(NeatNotifier notifier, dynamic action) {
    print('[Action] ${notifier.runtimeType}: $action');
  }

  @override
  void onStateChange(NeatNotifier notifier, dynamic state) {
    print('[State] ${notifier.runtimeType}: $state');
  }

  @override
  void onError(NeatNotifier notifier, Object error, StackTrace? stackTrace) {
    print('[Error] ${notifier.runtimeType}: $error');
  }
}

void main() {
  NeatNotifier.observer = MyLogger();
  runApp(MyApp());
}
```

## Interceptors

Interceptors allow you to inspect, transform, or block actions **before** they are emitted to listeners.

Each `NeatNotifier` has an `interceptors` list. You can add functions to this list.
- Return the action (modified or original) to pass it to the next interceptor.
- Return `null` to **block** the action.

```dart
class AuthNotifier extends NeatNotifier<AuthState, AuthAction> {
  AuthNotifier() : super(AuthState.initial()) {
    // Add an interceptor
    interceptors.add((action) {
      if (action is NavigateHome && !value.isAuthenticated) {
        // Block navigation if not authenticated
        return null; 
      }
      return action;
    });
  }
}
```

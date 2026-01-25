# neat_notifier

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Coverage Status](https://coveralls.io/repos/github/sla-000/flutter_neat_notifier/badge.svg?branch=main)](https://coveralls.io/github/sla-000/flutter_neat_notifier?branch=main)

A lightweight, feature-rich state management package for Flutter that builds upon `ValueNotifier` to provide a robust solution for handling states, one-time events, and asynchronous operations with built-in loading and error management.

## Features

- **Extends ValueNotifier**: Leverages the familiar and performant `ValueNotifier` API.
- **Built-in Async Support**: Easily manage `isLoading`, `error`, and `stackTrace` with the `runTask` method.
- **Event System**: Emit and listen to one-time events (e.g., showing a SnackBar or navigation) outside the main state.
- **Optimized Rebuilds**: `NeatBuilder` provides fine-grained control over widget rebuilds with a `rebuildWhen` callback.
- **Dedicated Builders**: Specific builders for `loading` and `error` states to keep your UI code clean.

## Getting started

Add `neat_notifier` to your `pubspec.yaml`:

```yaml
dependencies:
  neat_notifier: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## Usage

### 1. Define your Notifier

Create a class that extends `NeatNotifier`. Define your state and any events you might need.

```dart
typedef CounterState = ({int count});

sealed class CounterEvent {}
class MilestoneEvent extends CounterEvent {
  final String message;
  MilestoneEvent(this.message);
}

class CounterNotifier extends NeatNotifier<CounterState, CounterEvent> {
  CounterNotifier() : super((count: 0));

  Future<void> increment() => runTask(() async {
    await Future.delayed(const Duration(seconds: 1));
    value = (count: value.count + 1);
    
    if (value.count % 5 == 0) {
      emitEvent(MilestoneEvent('Reached ${value.count}!'));
    }
  });
}
```

### 2. Use NeatBuilder in your UI

```dart
NeatBuilder<CounterNotifier, CounterState, CounterEvent>(
  create: (context) => CounterNotifier(),
  onEvent: (context, notifier, event) {
    if (event is MilestoneEvent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
    }
  },
  loadingBuilder: (context, notifier, child) => Center(child: CircularProgressIndicator()),
  errorBuilder: (context, error, stackTrace, notifier, child) => Center(child: Text('Error: $error')),
  builder: (context, notifier, child) {
    return Column(
      children: [
        Text('Count: ${notifier.value.count}'),
        ElevatedButton(
          onPressed: notifier.increment,
          child: Text('Increment'),
        ),
      ],
    );
  },
)
```

## Additional information

For a detailed look at the core principles and architectural constraints of this project, please refer to the [RULES.md](RULES.md) file.

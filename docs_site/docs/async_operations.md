# Async Operations

`NeatNotifier` simplifies asynchronous operations with the `runTask` method. It automatically handles loading states and error capturing, allowing you to focus on your business logic.

## Using `runTask`

Wrap your async logic inside `runTask`. It will:
1. Set `isLoading` to `true`.
2. Clear any previous errors.
3. Execute your specific task.
4. Set `isLoading` to `false` when finished.
5. Capture any exceptions into the `error` property.

```dart
class UserNotifier extends NeatNotifier<String?, void> {
  UserNotifier() : super(null);

  Future<void> fetchUser() async {
    // runTask automatically handles isLoading and error records.
    await runTask(() async {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Update value on success
      value = 'John Doe';
    });
  }
}
```

## UI Handling

`NeatState` provides built-in builders for loading and error states, making it easy to show the appropriate UI.

```dart
NeatState<UserNotifier, String?, void>(
  create: (_) => UserNotifier(),
  
  // Custom loading UI
  loadingBuilder: (context, loading, child) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading user...'),
        ],
      ),
    );
  },
  
  // Custom error UI
  errorBuilder: (context, error, child) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text('Error: ${error.error}'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<UserNotifier>().fetchUser(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  },
  
  // Success UI
  builder: (context, user, child) {
    return Center(
      child: Text(
        user != null ? 'Welcome, $user!' : 'No user data.',
        style: const TextStyle(fontSize: 24),
      ),
    );
  },
)
```

## Accessing Loading State directly

You can also access the loading state manually if you are not using `NeatState` or want to use it in a different way (e.g. disabling a button).

```dart
final isLoading = context.select<UserNotifier, String?, bool>(
  (state) => context.read<UserNotifier>().isLoading
);
```

## Live Example

<iframe
  src="https://dartpad.dev/embed-flutter.html?id=e534a9215990eb21879624b7ce64664e"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>


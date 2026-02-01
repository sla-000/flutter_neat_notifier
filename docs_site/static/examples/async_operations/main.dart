import 'package:flutter/material.dart';
import 'package:neat_state/neat_state.dart';

void main() {
  runApp(const MyApp());
}

/// A notifier that simulates fetching a user name from a network.
class UserNotifier extends NeatNotifier<String?, void> {
  UserNotifier() : super(null);

  /// Fetches a user name asynchronously using [runTask].
  Future<void> fetchUser({bool simulateError = false}) async {
    // runTask automatically handles isLoading and error records.
    await runTask(() async {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (simulateError) {
        throw Exception('Failed to connect to the server');
      }

      // Manually update the value upon success.
      value = 'John Doe';
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: NeatState<UserNotifier, String?, void>(
        create: (_) => UserNotifier(),
        loadingBuilder: (context, loading, child) => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading user...'),
              ],
            ),
          ),
        ),
        errorBuilder: (context, error, child) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${error.error}'),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<UserNotifier>().fetchUser(),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
        builder: (context, user, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('NeatNotifier: runTask')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user != null ? 'Welcome, $user!' : 'No user data.',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            context.read<UserNotifier>().fetchUser(),
                        child: const Text('Fetch Success'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => context.read<UserNotifier>().fetchUser(
                          simulateError: true,
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Fetch Error'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

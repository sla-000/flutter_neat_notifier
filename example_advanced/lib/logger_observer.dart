import 'package:neat_state/neat_state.dart';
import 'dart:developer' as dev;

class LoggerObserver extends NeatObserver {
  @override
  void onAction(NeatNotifier notifier, dynamic action) {
    dev.log('Action: $action', name: notifier.runtimeType.toString());
  }

  @override
  void onStateChange(NeatNotifier notifier, dynamic state) {
    dev.log('State: $state', name: notifier.runtimeType.toString());
  }

  @override
  void onError(NeatNotifier notifier, Object error, StackTrace? stackTrace) {
    dev.log(
      'Error: $error',
      name: notifier.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}

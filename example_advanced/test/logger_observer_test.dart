import 'package:flutter_test/flutter_test.dart';
import 'package:example_advanced/logger_observer.dart';
import 'package:neat_notifier/neat_notifier.dart';

class TestNotifier extends NeatNotifier<int, String> {
  TestNotifier() : super(0);
}

void main() {
  group('LoggerObserver', () {
    test('GIVEN: LoggerObserver, '
        'WHEN: state changes or actions emitted, '
        'THEN: it does not throw (logs to developer console)', () {
      final observer = LoggerObserver();
      final notifier = TestNotifier();

      // We can't easily verify dev.log, but we can verify it doesn't crash
      observer.onStateChange(notifier, 1);
      observer.onAction(notifier, 'test');
      observer.onError(notifier, Exception('test'), null);
    });
  });
}

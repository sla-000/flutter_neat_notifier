import 'package:flutter_test/flutter_test.dart';
import 'package:neat_notifier/neat_notifier.dart';

class MockObserver extends NeatObserver {
  final List<dynamic> actions = [];
  final List<dynamic> states = [];
  final List<Object> errors = [];

  @override
  void onAction(NeatNotifier notifier, dynamic action) {
    actions.add(action);
  }

  @override
  void onStateChange(NeatNotifier notifier, dynamic state) {
    states.add(state);
  }

  @override
  void onError(NeatNotifier notifier, Object error, StackTrace? stackTrace) {
    errors.add(error);
  }
}

class TestNotifier extends NeatNotifier<int, String> {
  TestNotifier() : super(0);

  void increment() => value++;
  void doAction(String action) => emitAction(action);
  void fail() => setError('error');
}

void main() {
  late MockObserver observer;

  setUp(() {
    observer = MockObserver();
    NeatNotifier.observer = observer;
  });

  tearDown(() {
    NeatNotifier.observer = null;
  });

  group('NeatObserver', () {
    test('GIVEN: A NeatNotifier, '
        'WHEN: state changes, '
        'THEN: observer.onStateChange is called', () {
      final notifier = TestNotifier();
      notifier.increment();

      expect(observer.states, [1]);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: an action is emitted, '
        'THEN: observer.onAction is called', () {
      final notifier = TestNotifier();
      notifier.doAction('hello');

      expect(observer.actions, ['hello']);
    });

    test('GIVEN: A NeatNotifier, '
        'WHEN: an error occurs, '
        'THEN: observer.onError is called', () {
      final notifier = TestNotifier();
      notifier.fail();

      expect(observer.errors, ['error']);
    });
  });

  group('Interceptors', () {
    test('GIVEN: A notifier with an interceptor, '
        'WHEN: an action is emitted, '
        'THEN: the interceptor can transform the action', () {
      final notifier = TestNotifier();
      notifier.interceptors.add((a) => 'intercepted_$a');

      notifier.doAction('msg');

      expect(observer.actions, ['intercepted_msg']);
    });

    test('GIVEN: A notifier with an interceptor, '
        'WHEN: an interceptor returns null, '
        'THEN: the action is blocked', () async {
      final notifier = TestNotifier();
      notifier.interceptors.add((a) => null);

      String? receivedAction;
      notifier.actions.listen((a) => receivedAction = a);

      notifier.doAction('msg');

      // Give stream a chance to emit (it shouldn't)
      await Future.delayed(Duration.zero);

      expect(receivedAction, isNull);
      expect(observer.actions, isEmpty);
    });

    test('GIVEN: Multiple interceptors, '
        'WHEN: an action is emitted, '
        'THEN: they are executed in order', () {
      final notifier = TestNotifier();
      notifier.interceptors.add((a) => '${a}_1');
      notifier.interceptors.add((a) => '${a}_2');

      notifier.doAction('msg');

      expect(observer.actions, ['msg_1_2']);
    });
  });
}

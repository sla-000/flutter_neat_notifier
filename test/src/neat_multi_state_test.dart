import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_state/neat_state.dart';

class TestNotifier extends NeatNotifier<int, String> {
  TestNotifier([super.value = 0]);

  void increment() {
    value++;
  }
}

class AnotherNotifier extends NeatNotifier<String, void> {
  AnotherNotifier([super.value = 'initial']);

  void update(String newValue) {
    value = newValue;
  }
}

void main() {
  testWidgets('NeatMultiState provides multiple notifiers', (tester) async {
    await tester.pumpWidget(
      NeatMultiState(
        independent: [(_) => TestNotifier(10), (_) => AnotherNotifier('hello')],
        child: Builder(
          builder: (context) {
            final testVal = context.select<TestNotifier>()((s) => s);
            final anotherVal = context.select<AnotherNotifier>()((s) => s);
            return Text(
              '$testVal $anotherVal',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('10 hello'), findsOneWidget);

    final context = tester.element(find.byType(Builder));
    context.read<TestNotifier>().increment();
    await tester.pump();

    expect(find.text('11 hello'), findsOneWidget);

    context.read<AnotherNotifier>().update('world');
    await tester.pump();

    expect(find.text('11 world'), findsOneWidget);
  });

  testWidgets('NeatMultiState works with nested/dependent notifiers', (
    tester,
  ) async {
    await tester.pumpWidget(
      NeatMultiState(
        independent: [(_) => TestNotifier(10)],
        providers: [
          (child) => NeatState(
            create: (_) => AnotherNotifier('chained'),
            child: child,
          ),
        ],
        child: Builder(
          builder: (context) {
            final testVal = context.select<TestNotifier>()((s) => s);
            final anotherVal = context.select<AnotherNotifier>()((s) => s);
            return Text(
              'Combined: $testVal $anotherVal',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('Combined: 10 chained'), findsOneWidget);
  });
}

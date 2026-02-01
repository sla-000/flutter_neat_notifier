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
            final testVal = context.select<TestNotifier, int, int>((s) => s);
            final anotherVal = context.select<AnotherNotifier, String, String>(
              (s) => s,
            );
            return Text(
              '$testVal $anotherVal',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('10 hello'), findsOneWidget);

    // Update state through context.read
    final context = tester.element(find.text('10 hello'));
    context.read<TestNotifier>().increment();
    await tester.pump();

    expect(find.text('11 hello'), findsOneWidget);

    context.read<AnotherNotifier>().update('world');
    await tester.pump();

    expect(find.text('11 world'), findsOneWidget);
  });

  testWidgets('NeatMultiState works alongside NeatState', (tester) async {
    await tester.pumpWidget(
      NeatMultiState(
        independent: [(_) => TestNotifier(10)],
        child: NeatState(
          create: (_) => AnotherNotifier('nested'),
          child: Builder(
            builder: (context) {
              final testVal = context.select<TestNotifier, int, int>((s) => s);
              final anotherVal = context
                  .select<AnotherNotifier, String, String>((s) => s);
              return Text(
                '$testVal $anotherVal',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('10 nested'), findsOneWidget);
  });

  testWidgets('NeatState.of throws readable error when not found', (
    tester,
  ) async {
    await tester.pumpWidget(
      NeatMultiState(
        independent: [(_) => TestNotifier(10)],
        child: Builder(
          builder: (context) {
            // Trying to read a notifier that wasn't provided
            try {
              context.read<AnotherNotifier>();
            } catch (e) {
              return Text(e.toString(), textDirection: TextDirection.ltr);
            }
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      find.textContaining(
        'NeatState.of() called with a context that does not contain a AnotherNotifier',
      ),
      findsOneWidget,
    );
  });

  testWidgets('NeatMultiState supports codependent notifiers', (tester) async {
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
            final testVal = context.select<TestNotifier, int, int>((s) => s);
            final anotherVal = context.select<AnotherNotifier, String, String>(
              (s) => s,
            );
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

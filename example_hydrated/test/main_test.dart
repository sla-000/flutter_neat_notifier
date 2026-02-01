import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neat_state/neat_state.dart';
import 'package:example_hydrated/main.dart';

class MockNeatStorage implements NeatStorage {
  final Map<String, dynamic> _data = {};

  @override
  Object? read(String key) => _data[key];

  @override
  Future<void> write(String key, Object? value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

void main() {
  testWidgets('GIVEN: A new app, '
      'WHEN: it is launched, '
      'THEN: it should show the initial counter value (0)', (
    WidgetTester tester,
  ) async {
    NeatHydratedStorage.initialize(MockNeatStorage());
    await tester.pumpWidget(const HydratedApp());
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('GIVEN: An app with initial state, '
      'WHEN: the increment button is tapped, '
      'THEN: the counter should increase to 1', (WidgetTester tester) async {
    NeatHydratedStorage.initialize(MockNeatStorage());
    await tester.pumpWidget(const HydratedApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('GIVEN: A previous counter state of 42, '
      'WHEN: the app is launched, '
      'THEN: it should show the persisted value (42)', (
    WidgetTester tester,
  ) async {
    final storage = MockNeatStorage();
    await storage.write('counter_persistence', {'count': 42});
    NeatHydratedStorage.initialize(storage);

    await tester.pumpWidget(const HydratedApp());
    expect(find.text('42'), findsOneWidget);
  });
}

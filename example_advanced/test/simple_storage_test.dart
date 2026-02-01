import 'package:flutter_test/flutter_test.dart';
import 'package:example_advanced/simple_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimpleStorage', () {
    setUp(() {
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    test('GIVEN: SimpleStorage, '
        'WHEN: write and read are called, '
        'THEN: data is persisted in memory', () async {
      final storage = SimpleStorage();
      await storage.init();

      await storage.write('test', 'value');
      expect(storage.read('test'), 'value');
    });

    test('GIVEN: SimpleStorage with data, '
        'WHEN: delete is called, '
        'THEN: the key is removed', () async {
      final storage = SimpleStorage();
      await storage.init();

      await storage.write('test', 'value');
      expect(storage.read('test'), 'value');

      await storage.delete('test');
      expect(storage.read('test'), isNull);
    });

    test('GIVEN: SimpleStorage with data, '
        'WHEN: clear is called, '
        'THEN: all data is removed', () async {
      final storage = SimpleStorage();
      await storage.init();

      await storage.write('key1', 'value1');
      await storage.write('key2', 'value2');

      await storage.clear();
      expect(storage.read('key1'), isNull);
      expect(storage.read('key2'), isNull);
    });
  });
}

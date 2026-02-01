import 'package:flutter_test/flutter_test.dart';
import 'package:example/simple_storage.dart';
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
  });
}

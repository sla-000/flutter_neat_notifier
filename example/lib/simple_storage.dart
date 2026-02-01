import 'package:neat_notifier/neat_notifier.dart';

class SimpleStorage implements NeatStorage {
  final Map<String, Object?> _data = {};

  @override
  Object? read(String key) => _data[key];

  @override
  Future<void> write(String key, Object? value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

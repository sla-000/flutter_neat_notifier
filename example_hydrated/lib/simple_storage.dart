import 'dart:convert';
import 'dart:io';

import 'package:neat_state/neat_state.dart';
import 'package:path_provider/path_provider.dart';

class SimpleStorage implements NeatStorage {
  Map<String, Object?> _data = {};
  late File _file;

  /// Initializes the storage by loading data from a file in the support directory.
  Future<void> init() async {
    final supportDir = await getApplicationSupportDirectory();
    _file = File('${supportDir.path}/neat_storage.json');

    if (await _file.exists()) {
      try {
        final content = await _file.readAsString();
        _data = Map<String, Object?>.from(json.decode(content) as Map);
      } catch (e) {
        _data = {};
      }
    }
  }

  Future<void> _save() async {
    if (!await _file.exists()) {
      await _file.create(recursive: true);
    }
    await _file.writeAsString(json.encode(_data));
  }

  @override
  Object? read(String key) => _data[key];

  @override
  Future<void> write(String key, Object? value) async {
    _data[key] = value;
    await _save();
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
    await _save();
  }

  @override
  Future<void> clear() async {
    _data.clear();
    await _save();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// --- neat_state library start ---
// (Simplified for DartPad)

typedef NeatLoading = ({bool isUploading, int progress});
typedef NeatError = ({Object error, StackTrace? stackTrace});

class NeatNotifier<T, A> extends ValueNotifier<T> {
  NeatNotifier(super.value);
  @override
  set value(T newValue) {
    if (value == newValue) return;
    super.value = newValue;
  }

  final _actionController = StreamController<A>.broadcast();
  Stream<A> get actions => _actionController.stream;
  NeatError? _error;
  NeatLoading? _loading;
  bool get isLoading => _loading != null;
  void _updateInternalState({NeatLoading? loading, NeatError? error}) {
    if (_loading != loading) _loading = loading;
    if (_error != error) _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _actionController.close();
    super.dispose();
  }
}

abstract class NeatStorage {
  Object? read(String key);
  Future<void> write(String key, Object? value);
  Future<void> delete(String key);
  Future<void> clear();
}

class NeatHydratedStorage {
  NeatHydratedStorage._();
  static NeatStorage? _instance;
  static void initialize(NeatStorage storage) => _instance = storage;
  static NeatStorage get instance {
    if (_instance == null)
      throw FlutterError('NeatHydratedStorage not initialized');
    return _instance!;
  }
}

mixin NeatHydratedNotifier<T, A> on NeatNotifier<T, A> {
  String get id;
  T? fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T state);

  void hydrate() {
    final storage = NeatHydratedStorage.instance;
    final storedValue = storage.read(id);
    if (storedValue != null) {
      try {
        final Map<String, dynamic> json;
        if (storedValue is String) {
          json = jsonDecode(storedValue) as Map<String, dynamic>;
        } else {
          json = storedValue as Map<String, dynamic>;
        }
        final result = fromJson(json);
        if (result != null) value = result;
      } catch (e) {
        debugPrint('Error hydrating $id: $e');
      }
    }
    addListener(_persist);
  }

  void _persist() {
    final storage = NeatHydratedStorage.instance;
    storage.write(id, toJson(value));
  }
}

class NeatState<V extends NeatNotifier<S, A>, S, A> extends StatefulWidget {
  const NeatState({super.key, this.create, this.builder, this.child});
  final V Function(BuildContext context)? create;
  final Widget Function(BuildContext context, S state, Widget? child)? builder;
  final Widget? child;
  static V of<V extends NeatNotifier<dynamic, dynamic>>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_NeatInheritedProvider<V>>()!
        .notifier;
  }

  @override
  State<NeatState<V, S, A>> createState() => _NeatState<V, S, A>();
}

class _NeatState<V extends NeatNotifier<S, A>, S, A>
    extends State<NeatState<V, S, A>> {
  V? _notifier;
  @override
  void initState() {
    super.initState();
    if (widget.create != null) _notifier = widget.create!(context);
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notifier!.addListener(() => setState(() {}));
    return _NeatInheritedProvider<V>(
      notifier: _notifier!,
      state: _notifier!.value,
      child: widget.builder!(context, _notifier!.value, widget.child),
    );
  }
}

class _NeatInheritedProvider<V extends NeatNotifier<dynamic, dynamic>>
    extends InheritedWidget {
  const _NeatInheritedProvider({
    required this.notifier,
    required this.state,
    required super.child,
  });
  final V notifier;
  final dynamic state;
  @override
  bool updateShouldNotify(_NeatInheritedProvider<V> oldWidget) =>
      state != oldWidget.state;
}

extension NeatContextExtensions on BuildContext {
  V read<V extends NeatNotifier<dynamic, dynamic>>() => NeatState.of<V>(this);
}

// --- neat_state library end ---

// --- Mock Storage ---
class MemStorage implements NeatStorage {
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

// --- Example App ---

class SettingsNotifier extends NeatNotifier<ThemeMode, void>
    with NeatHydratedNotifier<ThemeMode, void> {
  SettingsNotifier() : super(ThemeMode.system) {
    hydrate();
  }
  @override
  String get id => 'settings';
  void toggle() =>
      value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values[json['theme'] as int];
  @override
  Map<String, dynamic> toJson(ThemeMode state) => {'theme': state.index};
}

void main() {
  NeatHydratedStorage.initialize(MemStorage());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return NeatState(
      create: (_) => SettingsNotifier(),
      builder: (context, mode, _) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Hydrated State Demo')),
            body: Center(child: Text('Current Mode: $mode')),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<SettingsNotifier>().toggle(),
              child: const Icon(Icons.brightness_4),
            ),
          ),
        );
      },
    );
  }
}

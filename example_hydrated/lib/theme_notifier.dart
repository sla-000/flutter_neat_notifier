import 'package:neat_notifier/neat_notifier.dart';

class ThemeNotifier extends NeatNotifier<bool, Never>
    with NeatHydratedNotifier<bool, Never> {
  ThemeNotifier() : super(false) {
    hydrate();
  }

  @override
  String get id => 'theme_persistence';

  void toggle() => value = !value;

  @override
  bool? fromJson(Map<String, dynamic> json) => json['isDarkMode'] as bool?;

  @override
  Map<String, dynamic> toJson(bool state) => {'isDarkMode': state};
}

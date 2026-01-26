import 'package:neat_notifier/neat_notifier.dart';

typedef SettingsState = ({bool isDarkMode});

sealed class SettingsEvent {}

class ThemeChangedEvent extends SettingsEvent {
  final bool isDarkMode;
  ThemeChangedEvent(this.isDarkMode);
}

class SettingsNotifier extends NeatNotifier<SettingsState, SettingsEvent> {
  SettingsNotifier() : super((isDarkMode: false));

  void toggleDarkMode() {
    value = (isDarkMode: !value.isDarkMode);
    emitEvent(ThemeChangedEvent(value.isDarkMode));
  }
}

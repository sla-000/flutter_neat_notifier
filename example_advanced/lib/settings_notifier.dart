import 'package:neat_state/neat_state.dart';

typedef SettingsState = ({bool isDarkMode});

sealed class SettingsAction {}

class ThemeChangedAction extends SettingsAction {
  final bool isDarkMode;
  ThemeChangedAction(this.isDarkMode);
}

class SettingsNotifier extends NeatNotifier<SettingsState, SettingsAction> {
  SettingsNotifier() : super((isDarkMode: false));

  void toggleDarkMode() {
    value = (isDarkMode: !value.isDarkMode);
    emitAction(ThemeChangedAction(value.isDarkMode));
  }
}

import 'package:flutter/widgets.dart';
import 'neat_notifier.dart';

/// A widget that provides multiple [NeatNotifier]s to its descendants.
///
/// This avoids the "pyramid of doom" when nesting multiple providers.
///
/// [independent]: A list of functions that create notifiers. These notifiers cannot depend on each other.
/// [providers]: A list of builders that will be nested. These CAN depend on notifiers in [independent] or previous items in [providers].
class NeatMultiState extends StatefulWidget {
  const NeatMultiState({
    required this.child,
    this.independent = const [],
    this.providers = const [],
    super.key,
  });

  /// Notifiers that do not depend on each other or context.
  final List<NeatNotifier Function(BuildContext context)> independent;

  /// [NeatState] widgets that are chained together.
  /// Allows subsequent notifiers to depend on previous ones.
  ///
  /// Each item is a builder that takes a child and returns a widget (usually [NeatState]).
  final List<Widget Function(Widget child)> providers;

  final Widget child;

  @override
  State<NeatMultiState> createState() => _NeatMultiStateState();
}

class _NeatMultiStateState extends State<NeatMultiState> {
  final Map<Type, NeatNotifier> _notifiers = {};
  final Map<Type, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    for (final create in widget.independent) {
      final notifier = create(context);
      _notifiers[notifier.runtimeType] = notifier;
      _values[notifier.runtimeType] = notifier.value;

      // Listen to changes to rebuild dependents
      notifier.addListener(() => _handleNotifierChange(notifier));
    }
  }

  void _handleNotifierChange(NeatNotifier notifier) {
    if (!mounted) return;
    setState(() {
      _values[notifier.runtimeType] = notifier.value;
    });
  }

  @override
  void dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Prepare independent providers (part of final build)

    // 2. Wrap provider widgets (in reverse order)
    Widget chainedChild = widget.child;

    for (final builder in widget.providers.reversed) {
      chainedChild = builder(chainedChild);
    }

    return NeatMultiInheritedProvider(
      notifiers: _notifiers,
      values: Map.of(_values),
      child: chainedChild,
    );
  }
}

class NeatMultiInheritedProvider extends InheritedModel<Type> {
  const NeatMultiInheritedProvider({
    super.key,
    required this.notifiers,
    required this.values,
    required super.child,
  });

  final Map<Type, NeatNotifier> notifiers;
  final Map<Type, dynamic> values;

  @override
  bool updateShouldNotify(NeatMultiInheritedProvider oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
    NeatMultiInheritedProvider oldWidget,
    Set<Type> dependencies,
  ) {
    for (final type in dependencies) {
      if (values[type] != oldWidget.values[type]) {
        return true;
      }
    }
    return false;
  }
}

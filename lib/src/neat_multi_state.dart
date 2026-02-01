import 'dart:async';
import 'package:flutter/widgets.dart';
import 'neat_notifier.dart';

/// A widget that provides multiple [NeatNotifier]s to its descendants.
///
/// This avoids the "pyramid of doom" when nesting multiple providers.
/// Notifiers declared here are siblings and cannot depend on each other during initialization.
class NeatMultiState extends StatefulWidget {
  const NeatMultiState({
    required this.createList,
    required this.child,
    super.key,
  });

  /// A list of functions that create [NeatNotifier]s.
  final List<NeatNotifier Function(BuildContext context)> createList;

  final Widget child;

  @override
  State<NeatMultiState> createState() => _NeatMultiStateState();
}

class _NeatMultiStateState extends State<NeatMultiState> {
  final Map<Type, NeatNotifier> _notifiers = {};
  final Map<Type, dynamic> _values = {};
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    for (final create in widget.createList) {
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
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeatMultiInheritedProvider(
      notifiers: _notifiers,
      values: Map.of(_values),
      child: widget.child,
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
    // If values map changed, we definitely need to define dependent updates
    // But since we mutate the map content in setState (which is okay for InheritedModel logic check usually, but here we replace values map in build?)
    // Actually, in build we pass reference. _values is mutated.
    // Wait, modifying _values in place and passing it again means oldWidget.values is same object.
    // FIX: create new map in build or handle change detection properly.
    // For simplicity heavily relying on updateShouldNotifyDependent.
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

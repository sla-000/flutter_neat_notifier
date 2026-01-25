import 'package:flutter/widgets.dart';

import 'ext_value_notifier.dart';

/// A widget that manages the lifecycle of an [ExtValueNotifier] and rebuilds
/// its children when the notifier updates based on custom logic.
///
/// [ExtNotifier] handles the creation and disposal of the [notifier] automatically.
class ExtNotifier<V extends ExtValueNotifier<S>, S> extends StatefulWidget {
  /// Creates an [ExtNotifier].
  ///
  /// The [create] callback is used to instantiate the [ExtValueNotifier].
  /// The [builder] callback is used to build the widget tree. It receives
  /// the [notifier] itself.
  /// The [child] is optional and can be used for optimization.
  /// The [rebuildWhen] callback allows for fine-grained control over rebuilds
  /// by comparing the previous and current state.
  /// The [errorBuilder] is called when the notifier has an active error.
  const ExtNotifier({
    super.key,
    required this.create,
    required this.builder,
    this.child,
    this.rebuildWhen,
    this.errorBuilder,
    this.loadingBuilder,
  });

  /// Function to create the [ExtValueNotifier] instance.
  final V Function(BuildContext context) create;

  /// Function that returns the widget tree.
  ///
  /// It is called whenever [rebuildWhen] returns true (or always if not provided).
  final Widget Function(BuildContext context, V notifier, Widget? child)
  builder;

  /// Optional builder that is called when the notifier has an active error.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    V notifier,
  )?
  errorBuilder;

  /// Optional builder that is called when the notifier is in a loading state.
  final Widget Function(BuildContext context, V notifier)? loadingBuilder;

  /// Optional callback to control when the widget rebuilds.
  ///
  /// Comparing [prev] and [curr] allows for optimized rebuilds.
  final bool Function(S prev, S curr)? rebuildWhen;

  /// Optional static child widget that is passed to the [builder].
  final Widget? child;

  @override
  State<ExtNotifier<V, S>> createState() => _ExtNotifierState<V, S>();
}

class _ExtNotifierState<V extends ExtValueNotifier<S>, S>
    extends State<ExtNotifier<V, S>> {
  late final V _notifier;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
    _previousState = _notifier.value;
    _notifier.addListener(_handleChange);
  }

  @override
  void dispose() {
    _notifier.removeListener(_handleChange);
    _notifier.dispose();
    super.dispose();
  }

  void _handleChange() {
    final currentState = _notifier.value;
    final shouldRebuild =
        widget.rebuildWhen?.call(_previousState, currentState) ?? true;
    _previousState = currentState;

    if (shouldRebuild || _notifier.error != null || _notifier.isLoading) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notifier.error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(
        context,
        _notifier.error!,
        _notifier.stackTrace,
        _notifier,
      );
    }
    if (_notifier.isLoading && widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _notifier);
    }
    return widget.builder(context, _notifier, widget.child);
  }
}

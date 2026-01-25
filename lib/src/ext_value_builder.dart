import 'dart:async';
import 'package:flutter/widgets.dart';

import 'ext_value_notifier.dart';

/// A widget that manages the lifecycle of an [ExtValueNotifier] and rebuilds
/// its children when the notifier updates based on custom logic.
///
/// [ExtValueBuilder] handles the creation and disposal of the [notifier] automatically.
class ExtValueBuilder<V extends ExtValueNotifier<S, E>, S, E>
    extends StatefulWidget {
  /// Creates an [ExtValueBuilder].
  ///
  /// The [create] callback is used to instantiate the [ExtValueNotifier].
  /// The [builder] callback is used to build the widget tree. It receives
  /// the [notifier] itself.
  /// The [child] is optional and can be used for optimization.
  /// The [rebuildWhen] callback allows for fine-grained control over rebuilds
  /// by comparing the previous and current state.
  /// The [errorBuilder] is called when the notifier has an active error.
  /// The [onEvent] callback is called when the notifier emits a one-time event.
  const ExtValueBuilder({
    super.key,
    required this.create,
    required this.builder,
    this.child,
    this.rebuildWhen,
    this.errorBuilder,
    this.loadingBuilder,
    this.onEvent,
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

  /// Optional callback called when a one-time event is emitted.
  final void Function(BuildContext context, V notifier, E event)? onEvent;

  /// Optional static child widget that is passed to the [builder].
  final Widget? child;

  @override
  State<ExtValueBuilder<V, S, E>> createState() =>
      _ExtValueBuilderState<V, S, E>();
}

class _ExtValueBuilderState<V extends ExtValueNotifier<S, E>, S, E>
    extends State<ExtValueBuilder<V, S, E>> {
  late final V _notifier;
  late S _previousState;
  StreamSubscription<E>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
    _previousState = _notifier.value;
    _notifier.addListener(_handleChange);
    _eventSubscription = _notifier.events.listen((event) {
      if (mounted) {
        widget.onEvent?.call(context, _notifier, event);
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
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

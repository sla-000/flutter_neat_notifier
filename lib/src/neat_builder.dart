import 'dart:async';
import 'package:flutter/widgets.dart';

import 'neat_notifier.dart';

/// A widget that manages the lifecycle of a [NeatNotifier] and rebuilds
/// its children when the notifier updates based on custom logic.
///
/// [NeatBuilder] handles the creation and disposal of the [notifier] automatically.
class NeatBuilder<V extends NeatNotifier<S, E>, S, E> extends StatefulWidget {
  /// Creates a [NeatBuilder].
  ///
  /// The [create] callback is used to instantiate the [NeatNotifier].
  /// The [builder] callback is used to build the widget tree. It receives
  /// the [notifier] itself.
  /// The [child] is optional and can be used for optimization.
  /// The [rebuildWhen] callback allows for fine-grained control over rebuilds
  /// by comparing the previous and current state.
  /// The [errorBuilder] is called when the notifier has an active error.
  /// The [onEvent] callback is called when the notifier emits a one-time event.
  const NeatBuilder({
    super.key,
    required this.create,
    required this.builder,
    this.child,
    this.rebuildWhen,
    this.errorBuilder,
    this.loadingBuilder,
    this.onEvent,
  });

  /// Function to create the [NeatNotifier] instance.
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
    Widget? child,
  )?
  errorBuilder;

  /// Optional builder that is called when the notifier is in a loading state.
  final Widget Function(BuildContext context, V notifier, Widget? child)?
  loadingBuilder;

  /// Optional callback to control when the widget rebuilds.
  ///
  /// Comparing [prev] and [curr] allows for optimized rebuilds.
  final bool Function(S prev, S curr)? rebuildWhen;

  /// Optional callback called when a one-time event is emitted.
  final void Function(BuildContext context, V notifier, E event)? onEvent;

  /// Optional static child widget that is passed to the builders.
  final Widget? child;

  @override
  State<NeatBuilder<V, S, E>> createState() => _NeatBuilderState<V, S, E>();
}

class _NeatBuilderState<V extends NeatNotifier<S, E>, S, E>
    extends State<NeatBuilder<V, S, E>> {
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
        widget.child,
      );
    }
    if (_notifier.isLoading && widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _notifier, widget.child);
    }
    return widget.builder(context, _notifier, widget.child);
  }
}

import 'dart:async';
import 'package:flutter/widgets.dart';

import 'neat_notifier.dart';

/// A widget that manages the lifecycle of a [NeatNotifier] and rebuilds
/// its children when the notifier updates based on custom logic.
///
/// [NeatState] can act as both a **Provider** and a **Builder**:
/// - If [create] is provided, it instantiates and manages the [notifier].
/// - If [create] is omitted, it looks up the nearest [NeatNotifier] of type [V]
///   in the widget tree.
class NeatState<V extends NeatNotifier<S, A>, S, A> extends StatefulWidget {
  /// Creates a [NeatState].
  ///
  /// The [create] callback is used to instantiate the [NeatNotifier]. If null,
  /// the widget will attempt to find an existing [V] in the widget tree.
  ///
  /// The [builder] callback is used to build the widget tree. If null, it
  /// defaults to returning the [child].
  ///
  /// The [child] is optional and can be used for optimization.
  /// The [rebuildWhen] callback allows for fine-grained control over rebuilds.
  /// The [errorBuilder] is called when the notifier has an active error.
  /// The [onAction] callback is called when the notifier emits a one-time action.
  const NeatState({
    super.key,
    this.create,
    this.builder,
    this.child,
    this.rebuildWhen,
    this.errorBuilder,
    this.loadingBuilder,
    this.onAction,
  });

  /// Function to create the [NeatNotifier] instance.
  final V Function(BuildContext context)? create;

  /// Function that returns the widget tree.
  final Widget Function(BuildContext context, S state, Widget? child)? builder;

  /// Optional builder that is called when the notifier has an active error.
  final Widget Function(BuildContext context, NeatError error, Widget? child)?
  errorBuilder;

  /// Optional builder that is called when the notifier is in a loading state.
  final Widget Function(
    BuildContext context,
    NeatLoading loading,
    Widget? child,
  )?
  loadingBuilder;

  /// Optional callback to control when the widget rebuilds.
  final bool Function(S prev, S curr)? rebuildWhen;

  /// Optional callback called when a one-time action is emitted.
  final void Function(BuildContext context, A action)? onAction;

  /// Optional static child widget that is passed to the builders.
  final Widget? child;

  /// Finds the nearest [NeatNotifier] of type [V] in the widget tree.
  ///
  /// If [listen] is true (default), the widget will rebuild when the notifier updates.
  /// An optional [aspect] can be provided to granularly control rebuilds.
  static V of<V extends NeatNotifier<dynamic, dynamic>>(
    BuildContext context, {
    bool listen = true,
    Object? aspect,
  }) {
    final provider = listen
        ? InheritedModel.inheritFrom<_NeatInheritedProvider<V>>(
            context,
            aspect: aspect,
          )
        : context.getInheritedWidgetOfExactType<_NeatInheritedProvider<V>>();

    if (provider == null) {
      throw FlutterError(
        'NeatState.of() called with a context that does not contain a $V.\n'
        'No ancestor could be found with that type. Make sure you have a parent NeatState that creates this notifier.',
      );
    }
    return provider.notifier;
  }

  @override
  State<NeatState<V, S, A>> createState() => _NeatState<V, S, A>();
}

class _NeatState<V extends NeatNotifier<S, A>, S, A>
    extends State<NeatState<V, S, A>> {
  V? _notifier;
  late S _previousState;
  StreamSubscription<A>? _actionSubscription;
  bool _isOwner = false;

  V get _effectiveNotifier => _notifier!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.create == null && _notifier == null) {
      _initNotifier(NeatState.of<V>(context, listen: false));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.create != null) {
      _isOwner = true;
      _initNotifier(widget.create!(context));
    }
  }

  void _initNotifier(V notifier) {
    _notifier = notifier;
    _previousState = _effectiveNotifier.value;
    _effectiveNotifier.addListener(_handleChange);
    _actionSubscription = _effectiveNotifier.actions.listen((action) {
      if (mounted) {
        widget.onAction?.call(context, action);
      }
    });
  }

  @override
  void dispose() {
    _actionSubscription?.cancel();
    _notifier?.removeListener(_handleChange);
    if (_isOwner) {
      _notifier?.dispose();
    }
    super.dispose();
  }

  void _handleChange() {
    final currentState = _effectiveNotifier.value;
    final shouldRebuild =
        widget.rebuildWhen?.call(_previousState, currentState) ?? true;
    _previousState = currentState;

    if (shouldRebuild ||
        _effectiveNotifier.error != null ||
        _effectiveNotifier.isLoading) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_effectiveNotifier.error != null && widget.errorBuilder != null) {
      content = widget.errorBuilder!(
        context,
        _effectiveNotifier.errorInfo!,
        widget.child,
      );
    } else if (_effectiveNotifier.isLoading && widget.loadingBuilder != null) {
      content = widget.loadingBuilder!(
        context,
        _effectiveNotifier.loading!,
        widget.child,
      );
    } else if (widget.builder != null) {
      content = widget.builder!(
        context,
        _effectiveNotifier.value,
        widget.child,
      );
    } else {
      content = widget.child ?? const SizedBox.shrink();
    }

    // Always wrap in a provider if we are managing/holding a notifier
    return _NeatInheritedProvider<V>(
      notifier: _effectiveNotifier,
      state: _effectiveNotifier.value,
      previousState: _previousState,
      child: content,
    );
  }
}

/// Internal widget that enables Dependency Injection and selectors for [NeatNotifier]s.
class _NeatInheritedProvider<V extends NeatNotifier<dynamic, dynamic>>
    extends InheritedModel<Object> {
  const _NeatInheritedProvider({
    required this.notifier,
    required this.state,
    required this.previousState,
    required super.child,
  });

  final V notifier;
  final dynamic state;
  final dynamic previousState;

  @override
  bool updateShouldNotify(_NeatInheritedProvider<V> oldWidget) =>
      notifier != oldWidget.notifier || state != oldWidget.state;

  @override
  bool updateShouldNotifyDependent(
    _NeatInheritedProvider<V> oldWidget,
    Set<Object> dependencies,
  ) {
    if (state != oldWidget.state) {
      for (final aspect in dependencies) {
        if (aspect is Function) {
          try {
            final oldSelected = aspect(oldWidget.state);
            final newSelected = aspect(state);
            if (oldSelected != newSelected) return true;
          } catch (_) {
            // If selector fails (e.g. type mismatch), safely rebuild
            return true;
          }
        } else {
          // Non-functional aspect? Fallback to rebuild
          return true;
        }
      }
    }
    return false;
  }
}

/// Extensions for easier access to [NeatNotifier]s from [BuildContext].
extension NeatContextExtensions on BuildContext {
  /// Retrieves the nearest [NeatNotifier] of type [V] without listening to it.
  V read<V extends NeatNotifier<dynamic, dynamic>>() =>
      NeatState.of<V>(this, listen: false);

  /// Retrieves the nearest [NeatNotifier] of type [V] and registers for rebuilds.
  V watch<V extends NeatNotifier<dynamic, dynamic>>() =>
      NeatState.of<V>(this, listen: true);

  /// Listens to a specific part of the state of the nearest [NeatNotifier] of type [V].
  ///
  /// [V] is the Notifier type.
  /// [S] is the State type of the notifier.
  /// [R] is the return type of the selector.
  R select<V extends NeatNotifier<S, dynamic>, S, R>(
    R Function(S state) selector,
  ) {
    final notifier = NeatState.of<V>(this, listen: true, aspect: selector);
    return selector(notifier.value);
  }
}

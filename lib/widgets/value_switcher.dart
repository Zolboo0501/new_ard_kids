import 'package:flutter/material.dart';

/// An [AnimatedSwitcher] for content that changes with [value].
///
/// Keying the switched child by the value itself (`key: ValueKey(text)`) is
/// the usual pattern, but it breaks on quick back-and-forth changes: flip
/// A → B → A → B inside one transition and the switcher holds two outgoing
/// copies under the same key, so Flutter throws "Duplicate keys found". This
/// gives every change its own key instead, so each child is unique however
/// fast the value flips.
///
/// ```dart
/// ValueSwitcher(
///   value: isLogin,
///   duration: const Duration(milliseconds: 240),
///   child: AppText(isLogin ? 'Нэвтрэх' : 'Бүртгүүлэх', size: 12),
/// )
/// ```
class ValueSwitcher<T> extends StatefulWidget {
  const ValueSwitcher({
    super.key,
    required this.value,
    required this.duration,
    required this.child,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.transitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  /// A change of this (by `==`) switches to the new [child].
  final T value;
  final Duration duration;
  final Widget child;
  final Curve switchInCurve;
  final Curve switchOutCurve;

  /// Like [AnimatedSwitcher.transitionBuilder], plus whether `child` is the
  /// one arriving (true) or one leaving (false), for transitions that move
  /// the two in different directions. Defaults to a fade.
  final Widget Function(
    Widget child,
    Animation<double> animation,
    bool incoming,
  )?
  transitionBuilder;

  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  State<ValueSwitcher<T>> createState() => _ValueSwitcherState<T>();
}

class _ValueSwitcherState<T> extends State<ValueSwitcher<T>> {
  /// Set in [initState], not lazily: a lazy initialiser would first run in
  /// [didUpdateWidget], already seeing the new value, and miss the change.
  late T _value;

  /// Bumped on every change of value; the current child's key.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(ValueSwitcher<T> old) {
    super.didUpdateWidget(old);
    if (widget.value != _value) {
      _value = widget.value;
      _generation++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ValueKey<int>(_generation);
    final transition = widget.transitionBuilder;
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: widget.switchInCurve,
      switchOutCurve: widget.switchOutCurve,
      layoutBuilder: widget.layoutBuilder,
      transitionBuilder: (child, animation) => transition == null
          ? AnimatedSwitcher.defaultTransitionBuilder(child, animation)
          : transition(child, animation, child.key == current),
      child: KeyedSubtree(key: current, child: widget.child),
    );
  }
}

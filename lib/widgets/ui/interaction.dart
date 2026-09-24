/// Tap haptics, keyboard dismissal and the press-to-scale wrapper.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a tap handler so it plays the app's tap haptic
/// ([HapticFeedback.selectionClick]) before running. `null` stays `null`, so
/// a disabled button stays disabled: `onTap: withHaptic(enabled ? save : null)`.
VoidCallback? withHaptic(VoidCallback? onTap) {
  if (onTap == null) return null;
  return () {
    HapticFeedback.selectionClick();
    onTap();
  };
}

/// Hides the on-screen keyboard by dropping focus from the current field.
/// Text fields pass it as `onTapOutside`, so tapping anywhere else on the
/// screen (a card, a button, empty space, or starting a scroll) closes it.
void dismissKeyboard([PointerDownEvent? _]) =>
    FocusManager.instance.primaryFocus?.unfocus();

/// Scales its child down slightly while pressed.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.scale = 0.97,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: () => _set(false),
      onTap: withHaptic(widget.onTap),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
}

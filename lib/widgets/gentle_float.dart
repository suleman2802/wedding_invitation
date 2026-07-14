import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Endlessly drifts its child up/down (and optionally rocks it) on a smooth
/// sine wave — used to give flowers, medallions and the envelope a gentle,
/// living motion. Pure transforms: no relayout, cheap on mobile.
class GentleFloat extends StatefulWidget {
  final Widget child;

  /// Maximum vertical travel in logical pixels.
  final double dy;

  /// Maximum rotation in radians (0 disables rocking).
  final double angle;

  /// Breathing amplitude: the child scales between 1-scale and 1+scale
  /// (0 disables breathing).
  final double scale;

  final Duration period;

  /// 0..1 phase offset so neighbouring floats don't move in lockstep.
  final double phase;

  const GentleFloat({
    super.key,
    required this.child,
    this.dy = 5,
    this.angle = 0,
    this.scale = 0,
    this.period = const Duration(seconds: 5),
    this.phase = 0,
  });

  @override
  State<GentleFloat> createState() => _GentleFloatState();
}

class _GentleFloatState extends State<GentleFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = 2 * math.pi * (_controller.value + widget.phase);
        Widget result = Transform.translate(
          offset: Offset(0, math.sin(t) * widget.dy),
          child: child,
        );
        if (widget.angle != 0) {
          result = Transform.rotate(
            angle: math.sin(t * 0.8) * widget.angle,
            child: result,
          );
        }
        if (widget.scale != 0) {
          result = Transform.scale(
            scale: 1 + math.sin(t) * widget.scale,
            child: result,
          );
        }
        return result;
      },
      child: widget.child,
    );
  }
}

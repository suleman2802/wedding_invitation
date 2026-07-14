import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Live countdown to [target], rendered as DAYS / HOURS / MINUTES / SECONDS
/// tiles in the invitation style.
class CountdownTimer extends StatefulWidget {
  final DateTime target;
  final Color color;

  const CountdownTimer({
    super.key,
    required this.target,
    this.color = WeddingColors.inkOnCream,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.target.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.target.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Text(
        'The celebration has begun!',
        style: WeddingType.serif(size: 20, color: widget.color),
        textAlign: TextAlign.center,
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _unit('$days', 'DAYS'),
        _separator(),
        _unit(_two(hours), 'HOURS'),
        _separator(),
        _unit(_two(minutes), 'MINUTES'),
        _separator(),
        _unit(_two(seconds), 'SECONDS'),
      ],
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  Widget _separator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          ':',
          style: WeddingType.display(
            size: 34,
            color: widget.color.withValues(alpha: 0.55),
          ),
        ),
      );

  Widget _unit(String value, String label) {
    return Column(
      children: [
        SizedBox(
          width: 58,
          height: 46,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.55),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                value,
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: WeddingType.display(size: 36, color: widget.color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: WeddingType.caps(
            size: 10,
            color: widget.color.withValues(alpha: 0.8),
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }
}

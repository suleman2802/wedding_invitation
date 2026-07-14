import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Petal {
  final double x; // horizontal start, fraction of width
  final double phase; // vertical start offset, fraction of cycle
  final double speed; // cycles per animation loop
  final double size;
  final double sway;
  final double spin;
  final Color color;

  const _Petal({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
    required this.sway,
    required this.spin,
    required this.color,
  });
}

class _PetalPainter extends CustomPainter {
  final double t;
  final List<_Petal> petals;

  _PetalPainter(this.t, this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final progress = (t * p.speed + p.phase) % 1.0;
      final y = progress * (size.height + 60) - 30;
      final x = p.x * size.width +
          math.sin(progress * 2 * math.pi * p.sway) * size.width * 0.05;
      final angle = progress * 2 * math.pi * p.spin;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final petal = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-p.size * 0.55, -p.size * 0.5, 0, -p.size)
        ..quadraticBezierTo(p.size * 0.55, -p.size * 0.5, 0, 0)
        ..close();
      canvas.drawPath(
        petal,
        Paint()..color = p.color.withValues(alpha: 0.75),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Softly falling rose petals, painted over the hero section.
class PetalRain extends StatefulWidget {
  final int count;
  const PetalRain({super.key, this.count = 16});

  @override
  State<PetalRain> createState() => _PetalRainState();
}

class _PetalRainState extends State<PetalRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

    final rnd = math.Random(11);
    const colors = [
      Color(0xFF8A1B3A),
      Color(0xFFB03A55),
      Color(0xFFF0E3D0),
      Color(0xFFD8A0AE),
    ];
    _petals = List.generate(widget.count, (i) {
      return _Petal(
        x: rnd.nextDouble(),
        phase: rnd.nextDouble(),
        speed: 1.5 + rnd.nextDouble() * 2.5,
        size: 7 + rnd.nextDouble() * 9,
        sway: 1 + rnd.nextDouble() * 2,
        spin: 1 + rnd.nextDouble() * 3,
        color: colors[i % colors.length],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _PetalPainter(_controller.value, _petals),
          size: Size.infinite,
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tiny deterministic pseudo-random generator so torn edges never "jump"
/// between rebuilds.
class _Lcg {
  int _state;
  _Lcg(int seed) : _state = seed & 0x7fffffff;

  double next() {
    _state = (_state * 48271) % 0x7fffffff;
    return _state / 0x7fffffff;
  }
}

/// Clips a rectangle so its top and/or bottom edge looks like torn paper,
/// with the tear reaching deepest near the horizontal centre — matching the
/// ripped-edge dividers of the reference design.
class TornEdgeClipper extends CustomClipper<Path> {
  final bool tearTop;
  final bool tearBottom;
  final double amplitude;
  final int seed;

  const TornEdgeClipper({
    this.tearTop = true,
    this.tearBottom = true,
    this.amplitude = 34,
    this.seed = 7,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final rnd = _Lcg(seed);

    List<Offset> edge(bool isTop) {
      final points = <Offset>[];
      const step = 16.0;
      final cx = size.width / 2;
      final sigma = size.width / 3.2;
      for (double x = 0; x <= size.width; x += step) {
        // Deeper tearing near the centre, calmer at the sides.
        final centreBias =
            0.25 + 0.75 * math.exp(-math.pow(x - cx, 2) / (2 * sigma * sigma));
        final rough = rnd.next();
        final depth = amplitude * centreBias * (0.25 + 0.75 * rough);
        final y = isTop ? depth : size.height - depth;
        points.add(Offset(x, y));
      }
      final endY = isTop ? amplitude * 0.2 : size.height - amplitude * 0.2;
      points.add(Offset(size.width, endY));
      return points;
    }

    if (tearTop) {
      final pts = edge(true);
      path.moveTo(0, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
    }

    if (tearBottom) {
      final pts = edge(false);
      path.lineTo(size.width, pts.last.dy);
      for (final p in pts.reversed) {
        path.lineTo(p.dx, p.dy);
      }
    } else {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TornEdgeClipper oldClipper) =>
      oldClipper.tearTop != tearTop ||
      oldClipper.tearBottom != tearBottom ||
      oldClipper.amplitude != amplitude ||
      oldClipper.seed != seed;
}

/// A full-bleed burgundy block with torn-paper edges, used to separate the
/// cream sections of the page.
class TornSection extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool tearTop;
  final bool tearBottom;
  final int seed;
  final EdgeInsetsGeometry padding;

  const TornSection({
    super.key,
    required this.child,
    required this.color,
    this.tearTop = true,
    this.tearBottom = true,
    this.seed = 7,
    this.padding = const EdgeInsets.symmetric(vertical: 64, horizontal: 28),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TornEdgeClipper(
        tearTop: tearTop,
        tearBottom: tearBottom,
        seed: seed,
      ),
      child: Container(
        width: double.infinity,
        color: color,
        padding: padding,
        child: child,
      ),
    );
  }
}

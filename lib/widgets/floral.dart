import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color _lighten(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Draws one lush peony: several rings of ruffle-edged petals that darken
/// towards a tight centre, with a soft drop shadow under the bloom.
void paintPeony(
  Canvas canvas,
  Offset center,
  double radius,
  Color color, {
  double rotation = 0,
  int seed = 3,
}) {
  final rnd = math.Random(seed);

  // Soft shadow grounding the bloom.
  canvas.drawCircle(
    center.translate(0, radius * 0.10),
    radius * 0.85,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.20)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.22),
  );

  // Outer ring first, then progressively smaller + darker rings on top.
  final rings = <({int petals, double frac})>[
    (petals: 13, frac: 1.00),
    (petals: 11, frac: 0.80),
    (petals: 9, frac: 0.60),
    (petals: 7, frac: 0.42),
    (petals: 5, frac: 0.27),
  ];

  for (var r = 0; r < rings.length; r++) {
    final ring = rings[r];
    final ringColor = _darken(color, 0.045 * r);
    final ringOffset = rotation + r * 0.45;

    for (int i = 0; i < ring.petals; i++) {
      final jitter = (rnd.nextDouble() - 0.5) * 0.18;
      final angle = ringOffset + i * 2 * math.pi / ring.petals + jitter;
      final len = radius * ring.frac * (0.90 + rnd.nextDouble() * 0.18);
      final w = len * 0.46;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      // Ruffled petal: smooth sides, scalloped outer edge.
      final r1 = rnd.nextDouble() * 0.08;
      final r2 = rnd.nextDouble() * 0.08;
      final r3 = rnd.nextDouble() * 0.08;
      final petal = Path()
        ..moveTo(0, 0)
        ..cubicTo(-w * 0.9, -len * 0.25, -w, -len * 0.70, -w * 0.55,
            -len * 0.88)
        ..quadraticBezierTo(
            -w * 0.30, -len * (1.02 + r1), -w * 0.12, -len * 0.94)
        ..quadraticBezierTo(0, -len * (1.06 + r2), w * 0.12, -len * 0.94)
        ..quadraticBezierTo(
            w * 0.30, -len * (1.02 + r3), w * 0.55, -len * 0.88)
        ..cubicTo(w, -len * 0.70, w * 0.9, -len * 0.25, 0, 0)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _darken(ringColor, 0.22),
            ringColor,
            _lighten(ringColor, 0.10),
            ringColor,
          ],
          stops: const [0.0, 0.45, 0.82, 1.0],
        ).createShader(Rect.fromLTRB(-w, -len * 1.1, w, 0));
      canvas.drawPath(petal, paint);

      canvas.drawPath(
        petal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(radius * 0.012, 0.6)
          ..color = _darken(ringColor, 0.28).withValues(alpha: 0.45),
      );
      canvas.restore();
    }
  }

  // Tight dark heart of the bloom.
  canvas.drawCircle(
    center,
    radius * 0.13,
    Paint()
      ..shader = RadialGradient(
        colors: [_darken(color, 0.38), _darken(color, 0.20)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.13)),
  );
}

void _paintLeaf(
  Canvas canvas,
  Offset base,
  double length,
  double angle, {
  Color color = const Color(0xFF44522C),
}) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angle);
  final w = length * 0.32;
  final leaf = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(-w, -length * 0.5, 0, -length)
    ..quadraticBezierTo(w, -length * 0.5, 0, 0)
    ..close();
  final paint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [_darken(color, 0.10), _lighten(color, 0.10)],
    ).createShader(Rect.fromLTRB(-w, -length, w, 0));
  canvas.drawPath(leaf, paint);
  // Centre vein.
  canvas.drawLine(
    Offset.zero,
    Offset(0, -length * 0.9),
    Paint()
      ..strokeWidth = 1
      ..color = _darken(color, 0.18).withValues(alpha: 0.7),
  );
  canvas.restore();
}

/// One flower placement inside a garland, in fractions of the widget size.
/// Listed back-to-front — later blooms overlap earlier ones.
class _Bloom {
  final double fx;
  final double fy;
  final double fr;
  final Color color;
  final double rotation;
  final int seed;
  const _Bloom(this.fx, this.fy, this.fr, this.color, this.rotation, this.seed);
}

class _GarlandPainter extends CustomPainter {
  static const _red = Color(0xFF8E1638);
  static const _deepRed = Color(0xFF6E0F2C);
  static const _cream = Color(0xFFF3EBDA);

  // Arranged like the reference: overlapping cluster building up to one
  // large bloom on the right.
  static const List<_Bloom> _blooms = [
    _Bloom(0.60, 0.42, 0.055, _deepRed, 0.8, 21), // small bud, back
    _Bloom(0.885, 0.38, 0.065, _red, 1.9, 22), // small bud, back
    _Bloom(0.18, 0.72, 0.115, _cream, 1.2, 11),
    _Bloom(0.06, 0.62, 0.125, _deepRed, 0.4, 12),
    _Bloom(0.43, 0.76, 0.115, _cream, 2.6, 13),
    _Bloom(0.30, 0.62, 0.150, _red, 2.1, 14),
    _Bloom(0.66, 0.78, 0.105, _cream, 0.9, 15),
    _Bloom(0.54, 0.64, 0.140, _deepRed, 1.5, 16),
    _Bloom(0.93, 0.70, 0.125, _deepRed, 2.3, 17),
    _Bloom(0.78, 0.55, 0.200, _red, 2.8, 18), // hero bloom, front
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height * 2.4);

    _paintLeaf(canvas, Offset(size.width * 0.14, size.height * 0.66),
        s * 0.18, -1.9);
    _paintLeaf(canvas, Offset(size.width * 0.50, size.height * 0.80),
        s * 0.20, 2.4);
    _paintLeaf(canvas, Offset(size.width * 0.70, size.height * 0.50),
        s * 0.19, 0.5);
    _paintLeaf(canvas, Offset(size.width * 0.36, size.height * 0.52),
        s * 0.16, -0.6);
    _paintLeaf(canvas, Offset(size.width * 0.90, size.height * 0.82),
        s * 0.17, 2.9);
    _paintLeaf(canvas, Offset(0.965 * size.width, size.height * 0.55),
        s * 0.15, 1.3);

    for (final b in _blooms) {
      paintPeony(
        canvas,
        Offset(size.width * b.fx, size.height * b.fy),
        s * b.fr,
        b.color,
        rotation: b.rotation,
        seed: b.seed,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GarlandPainter oldDelegate) => false;
}

/// A horizontal garland of painted peonies and roses, used as a decorative
/// band between sections and under the hero.
class FloralGarland extends StatelessWidget {
  final double height;
  const FloralGarland({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _GarlandPainter()),
      ),
    );
  }
}

/// Ornamental divider: a line — diamond — line motif.
class OrnamentDivider extends StatelessWidget {
  final Color color;
  final double width;
  const OrnamentDivider({
    super.key,
    this.color = WeddingColors.gold,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.7))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: 7, height: 7, color: color),
            ),
          ),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

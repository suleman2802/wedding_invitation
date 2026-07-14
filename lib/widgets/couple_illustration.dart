import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'floral.dart';

/// A stylised, hand-drawn-style silhouette of the couple — groom in a
/// sherwani and kulla cap, bride in a lehenga with a flowing dupatta —
/// holding hands beneath an arch of peonies. Used instead of photographs.
class CoupleIllustration extends StatelessWidget {
  final double height;
  const CoupleIllustration({super.key, this.height = 340});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height * 0.82,
      decoration: BoxDecoration(
        color: WeddingColors.cream,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: WeddingColors.gold.withValues(alpha: 0.75),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: CustomPaint(painter: _CouplePainter()),
      ),
    );
  }
}

class _CouplePainter extends CustomPainter {
  static const Color _silhouette = Color(0xFF4A0A20);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft radial glow behind the couple.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            WeddingColors.gold.withValues(alpha: 0.22),
            WeddingColors.gold.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.52), radius: w * 0.42),
        ),
    );

    _paintFloralArch(canvas, size);

    final ink = Paint()
      ..color = _silhouette
      ..style = PaintingStyle.fill;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.875),
        width: w * 0.52,
        height: h * 0.035,
      ),
      Paint()..color = _silhouette.withValues(alpha: 0.18),
    );

    _paintGroom(canvas, size, ink);
    _paintBride(canvas, size, ink);

    // Joined hands: a small heart where the arms meet.
    _paintHeart(canvas, Offset(w * 0.505, h * 0.545), w * 0.030,
        Paint()..color = const Color(0xFF8E2242));
  }

  void _paintFloralArch(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const colors = [
      Color(0xFF7A1230),
      Color(0xFFF4EAD8),
      Color(0xFF5E0B26),
      Color(0xFFF4EAD8),
      Color(0xFF7A1230),
    ];
    // Blooms along the top arc of the frame.
    for (int i = 0; i < 7; i++) {
      final t = i / 6.0;
      final angle = math.pi * (1.15 - t * 1.3); // sweep across the top
      final cx = w * 0.5 + math.cos(angle) * w * 0.40;
      final cy = h * 0.30 - math.sin(angle) * h * 0.20;
      paintPeony(
        canvas,
        Offset(cx, cy),
        w * (i.isEven ? 0.055 : 0.042),
        colors[i % colors.length],
        rotation: t * 2.2,
      );
    }
  }

  void _paintGroom(Canvas canvas, Size size, Paint ink) {
    final w = size.width;
    final h = size.height;

    // Head.
    canvas.drawCircle(Offset(w * 0.395, h * 0.395), w * 0.048, ink);
    // Kulla cap with a small turra plume.
    final cap = Path()
      ..moveTo(w * 0.352, h * 0.383)
      ..quadraticBezierTo(w * 0.395, h * 0.318, w * 0.438, h * 0.383)
      ..close();
    canvas.drawPath(cap, ink);
    canvas.drawCircle(Offset(w * 0.432, h * 0.335), w * 0.012, ink);

    // Sherwani body: high collar, straight shoulders, gentle flare at knee.
    final body = Path()
      ..moveTo(w * 0.395, h * 0.435) // neck
      ..lineTo(w * 0.330, h * 0.465) // left shoulder
      ..quadraticBezierTo(w * 0.312, h * 0.60, w * 0.330, h * 0.715) // side
      ..lineTo(w * 0.462, h * 0.715)
      ..quadraticBezierTo(w * 0.472, h * 0.58, w * 0.455, h * 0.468)
      ..close();
    canvas.drawPath(body, ink);

    // Legs.
    canvas.drawRect(
        Rect.fromLTRB(w * 0.352, h * 0.715, w * 0.382, h * 0.868), ink);
    canvas.drawRect(
        Rect.fromLTRB(w * 0.408, h * 0.715, w * 0.438, h * 0.868), ink);
    // Khussa shoes with a slight upturned toe.
    canvas.drawOval(
        Rect.fromLTRB(w * 0.340, h * 0.856, w * 0.392, h * 0.876), ink);
    canvas.drawOval(
        Rect.fromLTRB(w * 0.400, h * 0.856, w * 0.452, h * 0.876), ink);

    // Arm reaching to the bride.
    final arm = Paint()
      ..color = ink.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.448, h * 0.482)
        ..quadraticBezierTo(w * 0.492, h * 0.512, w * 0.502, h * 0.548),
      arm,
    );
  }

  void _paintBride(Canvas canvas, Size size, Paint ink) {
    final w = size.width;
    final h = size.height;

    // Head.
    canvas.drawCircle(Offset(w * 0.615, h * 0.415), w * 0.042, ink);

    // Dupatta: crescent flowing over the head and down the back.
    final dupatta = Path()
      ..moveTo(w * 0.568, h * 0.418)
      ..quadraticBezierTo(w * 0.598, h * 0.335, w * 0.668, h * 0.395)
      ..quadraticBezierTo(w * 0.712, h * 0.44, w * 0.708, h * 0.55)
      ..quadraticBezierTo(w * 0.688, h * 0.47, w * 0.652, h * 0.432)
      ..quadraticBezierTo(w * 0.612, h * 0.372, w * 0.568, h * 0.418)
      ..close();
    canvas.drawPath(dupatta, ink);

    // Bodice.
    final bodice = Path()
      ..moveTo(w * 0.615, h * 0.452)
      ..lineTo(w * 0.568, h * 0.478)
      ..lineTo(w * 0.585, h * 0.565)
      ..lineTo(w * 0.648, h * 0.565)
      ..lineTo(w * 0.662, h * 0.478)
      ..close();
    canvas.drawPath(bodice, ink);

    // Lehenga: full flared skirt with a softly scalloped hem.
    final skirt = Path()
      ..moveTo(w * 0.585, h * 0.560)
      ..quadraticBezierTo(w * 0.520, h * 0.72, w * 0.502, h * 0.862)
      ..quadraticBezierTo(w * 0.560, h * 0.876, w * 0.617, h * 0.868)
      ..quadraticBezierTo(w * 0.675, h * 0.876, w * 0.732, h * 0.862)
      ..quadraticBezierTo(w * 0.712, h * 0.72, w * 0.648, h * 0.560)
      ..close();
    canvas.drawPath(skirt, ink);

    // Arm reaching to the groom.
    final arm = Paint()
      ..color = ink.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.024
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.572, h * 0.492)
        ..quadraticBezierTo(w * 0.528, h * 0.516, w * 0.512, h * 0.548),
      arm,
    );
  }

  void _paintHeart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.3, c.dx - r * 0.7, c.dy - r * 1.4,
          c.dx, c.dy - r * 0.5)
      ..cubicTo(c.dx + r * 0.7, c.dy - r * 1.4, c.dx + r * 1.6, c.dy - r * 0.3,
          c.dx, c.dy + r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/wedding_audio.dart';
import '../theme.dart';

/// Loading opener modelled on the wrapped-envelope reel: the screen IS a
/// cream embossed envelope wrap, tied with a burgundy satin ribbon and
/// closed with the couple's wax seal. Tapping the seal unties the ribbon —
/// it slips down and away with the seal — then the two curved wrap flaps
/// peel open from the centre, revealing the envelope scene beneath.
///
/// Tap-driven so it doubles as the loading screen: tapping before [ready]
/// gives an excited seal wiggle and the wrap opens itself the moment
/// loading completes. Calls [onOpened] when fully revealed.
class EnvelopeUnseal extends StatefulWidget {
  final bool ready;
  final VoidCallback onOpened;

  const EnvelopeUnseal(
      {super.key, required this.ready, required this.onOpened});

  @override
  State<EnvelopeUnseal> createState() => _EnvelopeUnsealState();
}

class _EnvelopeUnsealState extends State<EnvelopeUnseal>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _wiggle;
  late final AnimationController _open;
  bool _pendingOpen = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _open.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onOpened();
    });
  }

  @override
  void didUpdateWidget(covariant EnvelopeUnseal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready && _pendingOpen) {
      _startOpen();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _wiggle.dispose();
    _open.dispose();
    super.dispose();
  }

  void _startOpen() {
    if (_opening) return;
    _opening = true;
    // Within the user's tap gesture, so the browser permits audio.
    WeddingAudio.start();
    _open.forward();
  }

  void _onTap() {
    if (_opening) return;
    if (widget.ready) {
      _startOpen();
    } else {
      _pendingOpen = true;
      _wiggle
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final flapW = w * 0.60;
            final sealSize = math.min(w * 0.30, 132.0);

            return AnimatedBuilder(
              animation: Listenable.merge([_idle, _wiggle, _open]),
              builder: (context, _) {
                final openT = _open.value;
                final idleT = _idle.value;

                final untie = const Interval(0.04, 0.30, curve: Curves.easeIn)
                    .transform(openT);
                final drop =
                    const Interval(0.16, 0.62, curve: Curves.easeInCubic)
                        .transform(openT);
                final part =
                    const Interval(0.50, 0.98, curve: Curves.easeInOutCubic)
                        .transform(openT);
                final textGone = const Interval(0.0, 0.14, curve: Curves.easeIn)
                    .transform(openT);
                final allGone = const Interval(0.88, 1.0, curve: Curves.easeIn)
                    .transform(openT);

                final wiggleT = _wiggle.value;
                final wiggleAngle = math.sin(wiggleT * math.pi * 5) *
                    (1 - wiggleT) *
                    0.07;

                return Opacity(
                  opacity: 1 - allGone,
                  child: Stack(
                    children: [
                      // Warm light spilling through as the wrap parts.
                      if (part > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity:
                                  (part * 0.7).clamp(0.0, 0.7),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    radius: 0.9,
                                    colors: [
                                      Color(0x66FFE9C4),
                                      Color(0x00FFE9C4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Left wrap flap.
                      Positioned(
                        left: 0,
                        top: 0,
                        width: flapW,
                        height: h,
                        child: IgnorePointer(
                          child: Transform.rotate(
                            angle: -0.10 * part,
                            alignment: Alignment.topLeft,
                            child: Transform.translate(
                              offset: Offset(-part * (flapW + 60), 0),
                              child: const RepaintBoundary(
                                child: CustomPaint(
                                  painter: _FlapPainter(isLeft: true),
                                  size: Size.infinite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right wrap flap.
                      Positioned(
                        right: 0,
                        top: 0,
                        width: flapW,
                        height: h,
                        child: IgnorePointer(
                          child: Transform.rotate(
                            angle: 0.10 * part,
                            alignment: Alignment.topRight,
                            child: Transform.translate(
                              offset: Offset(part * (flapW + 60), 0),
                              child: const RepaintBoundary(
                                child: CustomPaint(
                                  painter: _FlapPainter(isLeft: false),
                                  size: Size.infinite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Ribbon + bow + seal, slipping down and away.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: h,
                        child: IgnorePointer(
                          child: Transform.translate(
                            offset: Offset(0, drop * h * 1.2),
                            child: Transform.rotate(
                              angle: 0.06 * drop,
                              child: Stack(
                                children: [
                                  // Satin band across the centre.
                                  Positioned(
                                    left: -20,
                                    right: -20,
                                    top: h / 2 - 30,
                                    height: 60,
                                    child: const RepaintBoundary(
                                      child: CustomPaint(
                                        painter: _RibbonBandPainter(),
                                        size: Size.infinite,
                                      ),
                                    ),
                                  ),
                                  // Bow loops + tails, loosening first.
                                  Positioned(
                                    left: w / 2 - sealSize * 1.35,
                                    top: h / 2 - sealSize * 0.95,
                                    width: sealSize * 2.7,
                                    height: sealSize * 1.9,
                                    child: Opacity(
                                      opacity:
                                          (1 - untie).clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 1 - 0.35 * untie,
                                        child: const RepaintBoundary(
                                          child: CustomPaint(
                                            painter: _BowPainter(),
                                            size: Size.infinite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Wax seal.
                                  Positioned(
                                    left: w / 2 - sealSize / 2,
                                    top: h / 2 - sealSize / 2,
                                    width: sealSize,
                                    height: sealSize,
                                    child: Transform.rotate(
                                      angle: wiggleAngle,
                                      child: Transform.scale(
                                        scale: 1 +
                                            0.035 *
                                                math.sin(idleT *
                                                    2 *
                                                    math.pi) *
                                                (1 - openT),
                                        child: _Seal(size: sealSize),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Suspense text.
                      Positioned(
                        left: 30,
                        right: 30,
                        top: h / 2 + sealSize * 0.85 + 26,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: (1 - textGone).clamp(0.0, 1.0),
                            child: Column(
                              children: [
                                Text(
                                  'You are cordially invited…',
                                  textAlign: TextAlign.center,
                                  style: WeddingType.script(
                                    size: 30,
                                    color: WeddingColors.burgundy,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Opacity(
                                  opacity: 0.82 +
                                      0.18 *
                                          math.sin(
                                              idleT * 2 * math.pi),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: WeddingColors.deepBurgundy
                                          .withValues(alpha: 0.90),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                      border: Border.all(
                                        color: WeddingColors.gold
                                            .withValues(alpha: 0.65),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.touch_app_outlined,
                                            color:
                                                WeddingColors.softCream,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.ready || !_pendingOpen
                                              ? 'TAP THE SEAL TO OPEN'
                                              : 'ALMOST READY…',
                                          textAlign: TextAlign.center,
                                          style: WeddingType.caps(
                                            size: 12,
                                            color:
                                                WeddingColors.softCream,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Wax seal with a properly engraved stamp face — dotted ring, curved
/// "INVITATION" lettering and a botanical rose emblem, all pressed into the
/// wax with a relief effect.
class _Seal extends StatelessWidget {
  final double size;
  const _Seal({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _SealPainter());
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter();

  static const _face = Color(0xFFF3D8CD);
  static const _press = Color(0xFF3A0616);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Poured-wax blob.
    final blob = Path();
    const points = 24;
    final rnd = math.Random(9);
    for (int i = 0; i <= points; i++) {
      final angle = i / points * 2 * math.pi;
      final wobble = 0.86 + rnd.nextDouble() * 0.14;
      final p =
          center + Offset(math.cos(angle), math.sin(angle)) * r * wobble;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();

    canvas.drawShadow(blob, Colors.black87, 6, false);
    canvas.drawPath(
      blob,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: const [
            Color(0xFF8E2242),
            Color(0xFF64102D),
            Color(0xFF490A21),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // Pressed stamp bed: a slightly darker disc the design sits in.
    canvas.drawCircle(
      center,
      r * 0.78,
      Paint()..color = _press.withValues(alpha: 0.25),
    );

    // Dotted ring.
    for (int i = 0; i < 40; i++) {
      final a = i / 40 * 2 * math.pi;
      final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.72;
      _engraveDot(canvas, p, r * 0.020);
    }

    // Inner solid ring.
    _engraveCircle(canvas, center, r * 0.62, r * 0.020);

    // Curved lettering along the top arc.
    _arcText(canvas, center, 'INVITATION', r * 0.455, r * 0.155);

    // Small diamonds flanking the lower arc.
    for (final side in [-1.0, 1.0]) {
      final a = math.pi / 2 + side * 0.85;
      final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.46;
      _engraveDiamond(canvas, p, r * 0.045);
    }

    // Central engraved rose: spiral heart + two petal rings.
    final rc = center.translate(0, r * 0.10);
    _engraveCircle(canvas, rc, r * 0.055, r * 0.018);
    for (int i = 0; i < 5; i++) {
      final a = i / 5 * 2 * math.pi + 0.3;
      _engraveArc(canvas, rc + Offset(math.cos(a), math.sin(a)) * r * 0.10,
          r * 0.075, a - 1.9, 2.6, r * 0.018);
    }
    for (int i = 0; i < 7; i++) {
      final a = i / 7 * 2 * math.pi;
      _engraveArc(canvas, rc + Offset(math.cos(a), math.sin(a)) * r * 0.175,
          r * 0.085, a - 1.7, 2.2, r * 0.018);
    }
    // Leaves either side of the rose.
    for (final side in [-1.0, 1.0]) {
      final base = rc + Offset(side * r * 0.30, r * 0.06);
      _engraveLeaf(canvas, base, side, r);
    }
  }

  // --- relief engraving helpers: dark pass offset, then light pass ------

  static const _reliefOffset = Offset(0.9, 1.3);

  void _engraveDot(Canvas c, Offset p, double radius) {
    c.drawCircle(p + _reliefOffset, radius,
        Paint()..color = _press.withValues(alpha: 0.7));
    c.drawCircle(p, radius, Paint()..color = _face);
  }

  void _engraveCircle(Canvas c, Offset p, double radius, double w) {
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = _press.withValues(alpha: 0.7);
    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = _face;
    c.drawCircle(p + _reliefOffset, radius, dark);
    c.drawCircle(p, radius, light);
  }

  void _engraveArc(Canvas c, Offset p, double radius, double start,
      double sweep, double w) {
    final rect = Rect.fromCircle(center: p, radius: radius);
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = _press.withValues(alpha: 0.7);
    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = _face;
    c.drawArc(rect.shift(_reliefOffset), start, sweep, false, dark);
    c.drawArc(rect, start, sweep, false, light);
  }

  void _engraveDiamond(Canvas c, Offset p, double s) {
    Path d(Offset o) => Path()
      ..moveTo(o.dx, o.dy - s)
      ..lineTo(o.dx + s * 0.7, o.dy)
      ..lineTo(o.dx, o.dy + s)
      ..lineTo(o.dx - s * 0.7, o.dy)
      ..close();
    c.drawPath(
        d(p + _reliefOffset), Paint()..color = _press.withValues(alpha: 0.7));
    c.drawPath(d(p), Paint()..color = _face);
  }

  void _engraveLeaf(Canvas c, Offset base, double side, double r) {
    Path leaf(Offset o) => Path()
      ..moveTo(o.dx, o.dy)
      ..quadraticBezierTo(o.dx + side * r * 0.10, o.dy - r * 0.10,
          o.dx + side * r * 0.20, o.dy - r * 0.05)
      ..quadraticBezierTo(o.dx + side * r * 0.10, o.dy + r * 0.02,
          o.dx, o.dy)
      ..close();
    c.drawPath(leaf(base + _reliefOffset),
        Paint()..color = _press.withValues(alpha: 0.7));
    c.drawPath(
        leaf(base),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.016
          ..color = _face);
  }

  void _arcText(Canvas canvas, Offset center, String text, double radius,
      double fontSize) {
    const arc = 2.4; // radians spanned by the whole word
    final step = arc / (text.length - 1);
    for (int i = 0; i < text.length; i++) {
      final a = -arc / 2 + i * step; // 0 = straight up
      final pos = center +
          Offset(math.sin(a) * radius, -math.cos(a) * radius);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(a);
      for (final (offset, color) in [
        (_reliefOffset, _press.withValues(alpha: 0.7)),
        (Offset.zero, _face),
      ]) {
        final tp = TextPainter(
          text: TextSpan(
            text: text[i],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas, offset + Offset(-tp.width / 2, -tp.height / 2));
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}

const _satinHi = Color(0xFF8E2242);
const _satinMid = Color(0xFF61102E);
const _satinLo = Color(0xFF490A21);

/// Horizontal satin ribbon band.
class _RibbonBandPainter extends CustomPainter {
  const _RibbonBandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_satinHi, _satinMid, _satinLo],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    canvas.drawLine(
      Offset(0, size.height * 0.24),
      Offset(size.width, size.height * 0.24),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 1.4,
    );
    final edge = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(0, 1), Offset(size.width, 1), edge);
    canvas.drawLine(Offset(0, size.height - 1),
        Offset(size.width, size.height - 1), edge);
  }

  @override
  bool shouldRepaint(covariant _RibbonBandPainter oldDelegate) => false;
}

/// Bow loops and tails behind the seal. Design space 270×190.
class _BowPainter extends CustomPainter {
  const _BowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 270, size.height / 190);

    final loopPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_satinHi, _satinMid, _satinLo],
      ).createShader(const Rect.fromLTWH(20, 40, 230, 110));
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _satinLo.withValues(alpha: 0.9);

    // Tails first (behind the loops).
    final tailPaint = Paint()..color = _satinMid;
    final leftTail = Path()
      ..moveTo(120, 105)
      ..lineTo(74, 168)
      ..lineTo(96, 168)
      ..lineTo(100, 148)
      ..close();
    final rightTail = Path()
      ..moveTo(150, 105)
      ..lineTo(196, 168)
      ..lineTo(174, 168)
      ..lineTo(170, 148)
      ..close();
    canvas.drawPath(leftTail, tailPaint);
    canvas.drawPath(rightTail, tailPaint);

    // Loops.
    final leftLoop = Path()
      ..moveTo(135, 95)
      ..cubicTo(85, 45, 30, 60, 48, 100)
      ..cubicTo(58, 120, 105, 118, 135, 95)
      ..close();
    final rightLoop = Path()
      ..moveTo(135, 95)
      ..cubicTo(185, 45, 240, 60, 222, 100)
      ..cubicTo(212, 120, 165, 118, 135, 95)
      ..close();
    canvas.drawPath(leftLoop, loopPaint);
    canvas.drawPath(leftLoop, outline);
    canvas.drawPath(rightLoop, loopPaint);
    canvas.drawPath(rightLoop, outline);
  }

  @override
  bool shouldRepaint(covariant _BowPainter oldDelegate) => false;
}

/// One curved wrap flap of the envelope: cream paper with a blind-embossed
/// floral pattern and a softly shaded curved inner edge.
class _FlapPainter extends CustomPainter {
  final bool isLeft;
  const _FlapPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (!isLeft) {
      // Mirror the right flap so one drawing serves both sides.
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    // Curved inner edge: bulges toward the seam mid-height.
    final flap = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.88, 0)
      ..cubicTo(w * 0.80, h * 0.22, w * 1.02, h * 0.38, w * 0.99,
          h * 0.52)
      ..cubicTo(w * 0.96, h * 0.68, w * 0.78, h * 0.80, w * 0.86, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(flap.shift(const Offset(4, 0)), Colors.black54, 8,
        false);
    canvas.drawPath(
      flap,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFBF3E6), Color(0xFFF3E6D0)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Blind-embossed sprigs.
    final rnd = math.Random(isLeft ? 4 : 11);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFDCC5AA).withValues(alpha: 0.55);
    for (int i = 0; i < 16; i++) {
      final x = rnd.nextDouble() * w * 0.85;
      final y = rnd.nextDouble() * h;
      final len = 30 + rnd.nextDouble() * 34;
      final angle = rnd.nextDouble() * math.pi * 2;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      final stem = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.2, -len * 0.5, 0, -len);
      canvas.drawPath(stem, stroke);
      for (double f = 0.25; f < 1; f += 0.22) {
        canvas.drawCircle(Offset(4, -len * f), 2.2, stroke);
        canvas.drawCircle(Offset(-4, -len * f + 4), 2.2, stroke);
      }
      canvas.restore();
    }

    // Soft shading along the curved inner edge.
    canvas.drawPath(
      flap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFD9BF9F).withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _FlapPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft;
}

/// Exposed for the visual render tool in tests.
const CustomPainter debugFlapLeft = _FlapPainter(isLeft: true);
const CustomPainter debugFlapRight = _FlapPainter(isLeft: false);
const CustomPainter debugRibbonBand = _RibbonBandPainter();
const CustomPainter debugBow = _BowPainter();
const CustomPainter debugSeal = _SealPainter();

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../wedding_config.dart';

/// Full-screen envelope intro. The wax seal pulses gently; on tap the seal
/// melts away, the flap swings open in 3D, a letter rises from the pocket and
/// the whole envelope fades out to reveal the invitation underneath.
class EnvelopeOverlay extends StatefulWidget {
  final VoidCallback onOpened;
  const EnvelopeOverlay({super.key, required this.onOpened});

  @override
  State<EnvelopeOverlay> createState() => _EnvelopeOverlayState();
}

class _EnvelopeOverlayState extends State<EnvelopeOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _open;
  late final AnimationController _pulse;
  bool _opening = false;

  late final Animation<double> _sealScale;
  late final Animation<double> _flapTurn;
  late final Animation<double> _letterRise;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _sealScale = CurvedAnimation(
      parent: _open,
      curve: const Interval(0.0, 0.22, curve: Curves.easeInBack),
    );
    _flapTurn = CurvedAnimation(
      parent: _open,
      curve: const Interval(0.15, 0.55, curve: Curves.easeInOutCubic),
    );
    _letterRise = CurvedAnimation(
      parent: _open,
      curve: const Interval(0.45, 0.82, curve: Curves.easeOutCubic),
    );
    _fadeOut = CurvedAnimation(
      parent: _open,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );

    _open.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onOpened();
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    if (_opening) return;
    setState(() => _opening = true);
    _pulse.stop();
    _open.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_open, _pulse]),
          builder: (context, _) {
            return Opacity(
              opacity: 1 - _fadeOut.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      WeddingColors.darkestBurgundy,
                      WeddingColors.deepBurgundy,
                      WeddingColors.burgundy,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w =
                        math.min(constraints.maxWidth * 0.88, 420.0);
                    final h = math.min(
                        constraints.maxHeight * 0.72, w * 1.35);
                    // Gentle idle bob while waiting to be opened.
                    final bob = math.sin(_pulse.value * math.pi) *
                        6 *
                        (1 - _open.value);
                    return Transform.translate(
                      offset: Offset(0, bob),
                      child: Transform.scale(
                        scale: 1 + _fadeOut.value * 0.25,
                        child: SizedBox(
                          width: w,
                          height: h,
                          child: _buildEnvelope(w, h),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnvelope(double w, double h) {
    final flapHeight = h * 0.5;
    final flapAngle = _flapTurn.value * math.pi;
    final flapBehind = flapAngle > math.pi / 2;
    final sealSize = w * 0.26;

    final letter = _buildLetter(w, h);
    final flap = _buildFlap(w, flapHeight, flapAngle);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Envelope back panel.
        _panel(w, h, const Color(0xFFF9EFE3)),
        // Embossed floral pattern on the back.
        Positioned.fill(
          child: CustomPaint(painter: _EmbossPainter()),
        ),
        // Letter rising out of the pocket.
        Positioned(
          top: h * 0.16 - _letterRise.value * h * 0.34,
          child: Opacity(
            opacity: _opening ? 1 : 0,
            child: letter,
          ),
        ),
        // Side and bottom pockets drawn over the letter.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _PocketPainter()),
          ),
        ),
        // Flap: in front of pockets while closed, behind once fully open.
        if (!flapBehind) Positioned(top: 0, child: flap),
        // Wax seal sits on the flap tip — the vertical centre of the envelope.
        Positioned(
          top: flapHeight - sealSize / 2,
          child: Transform.scale(
            scale: (1 - _sealScale.value) *
                (1 + 0.045 * math.sin(_pulse.value * math.pi)),
            child: _WaxSeal(size: sealSize),
          ),
        ),
        // Tap hint.
        Positioned(
          bottom: h * 0.08,
          child: Opacity(
            opacity: (1 - _open.value * 4).clamp(0.0, 1.0) *
                (0.55 + 0.45 * _pulse.value),
            child: Column(
              children: [
                const Icon(Icons.keyboard_arrow_up,
                    color: Color(0xFF9C6A57), size: 22),
                Text(
                  'TAP TO OPEN',
                  style: WeddingType.caps(
                    size: 12,
                    color: const Color(0xFF9C6A57),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(double w, double h, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 46,
            offset: const Offset(0, 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFlap(double w, double flapHeight, double angle) {
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0016)
        ..rotateX(angle),
      child: CustomPaint(
        size: Size(w, flapHeight),
        painter: _FlapPainter(),
      ),
    );
  }

  Widget _buildLetter(double w, double h) {
    return Container(
      width: w * 0.86,
      height: h * 0.62,
      decoration: BoxDecoration(
        color: WeddingColors.cream,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: WeddingColors.gold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
            textDirection: TextDirection.rtl,
            style: WeddingType.arabic(size: 18, color: WeddingColors.gold),
          ),
          const SizedBox(height: 10),
          Text(
            'Together with their families',
            style: WeddingType.caps(
              size: 10,
              color: WeddingColors.inkOnCream.withValues(alpha: 0.7),
              letterSpacing: 2.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            WeddingConfig.groomShort,
            style: WeddingType.script(
                size: 38, color: WeddingColors.burgundy),
          ),
          Text(
            '&',
            style: WeddingType.script(
                size: 24, color: WeddingColors.gold),
          ),
          Text(
            WeddingConfig.brideShort,
            style: WeddingType.script(
                size: 38, color: WeddingColors.burgundy),
          ),
        ],
      ),
    );
  }
}

/// Top flap: a classic envelope triangle with a soft edge shadow.
class _FlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flap = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..quadraticBezierTo(w * 0.78, h * 0.42, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.22, h * 0.42, 0, 0)
      ..close();

    canvas.drawShadow(flap, Colors.black54, 6, false);
    canvas.drawPath(
      flap,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6EBD9), Color(0xFFEDDCC4)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawPath(
      flap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFD9BFA4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Side + bottom pockets of the envelope, meeting under the flap tip like a
/// classic envelope back.
class _PocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final left = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.46, h * 0.50, w * 0.5, h * 0.55)
      ..lineTo(0, h)
      ..close();
    final right = Path()
      ..moveTo(w, 0)
      ..quadraticBezierTo(w * 0.54, h * 0.50, w * 0.5, h * 0.55)
      ..lineTo(w, h)
      ..close();
    final bottom = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.5, h * 0.44, w, h)
      ..close();

    final side = Paint()..color = const Color(0xFFF2E2CE);
    final bottomPaint = Paint()..color = const Color(0xFFF6E9D6);
    final crease = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFD9BFA4).withValues(alpha: 0.8);

    canvas.drawPath(left, side);
    canvas.drawPath(right, side);
    canvas.drawPath(bottom, bottomPaint);
    canvas.drawPath(left, crease);
    canvas.drawPath(right, crease);
    canvas.drawPath(bottom, crease);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Faint tone-on-tone sprigs, like blind embossing on the paper.
class _EmbossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(4);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFD9C2A8).withValues(alpha: 0.55);

    for (int i = 0; i < 14; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final len = 26 + rnd.nextDouble() * 30;
      final angle = rnd.nextDouble() * math.pi * 2;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      final stem = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.2, -len * 0.5, 0, -len);
      canvas.drawPath(stem, stroke);
      for (double f = 0.25; f < 1; f += 0.22) {
        final py = -len * f;
        canvas.drawCircle(Offset(4, py), 2.1, stroke);
        canvas.drawCircle(Offset(-4, py + 4), 2.1, stroke);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaxSeal extends StatelessWidget {
  final double size;
  const _WaxSeal({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WaxSealPainter(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size * 0.20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                WeddingConfig.sealMonogram,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: WeddingType.script(
                  size: 40,
                  color: const Color(0xFFF3D8CD),
                  shadows: [
                    const Shadow(
                      color: Color(0xFF3A0616),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaxSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Irregular blob edge, like poured wax.
    final blob = Path();
    const points = 22;
    final rnd = math.Random(9);
    for (int i = 0; i <= points; i++) {
      final angle = i / points * 2 * math.pi;
      final wobble = 0.86 + rnd.nextDouble() * 0.14;
      final p = center +
          Offset(math.cos(angle), math.sin(angle)) * r * wobble;
      if (i == 0) {
        blob.moveTo(p.dx, p.dy);
      } else {
        blob.lineTo(p.dx, p.dy);
      }
    }
    blob.close();

    canvas.drawShadow(blob, Colors.black87, 5, false);
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

    // Inner stamped ring.
    canvas.drawCircle(
      center,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFF3D8CD).withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

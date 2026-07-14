import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// The couple artwork in a cream medallion arched with the wedding flowers.
///
/// If assets/couple/couple.png (or .webp) exists it is shown tinted in the
/// wedding burgundy — drop in any transparent-background silhouette and it
/// matches the colour scheme automatically. Until then, the built-in painted
/// silhouette is used.
class CoupleIllustration extends StatelessWidget {
  final double height;
  const CoupleIllustration({super.key, this.height = 340});

  /// Asset key of the user-provided silhouette, or null. Resolved once.
  static Future<String?>? _coupleAsset;

  static Future<String?> _resolveCoupleAsset() async {
    for (final ext in ['png', 'webp']) {
      final key = 'assets/couple/couple.$ext';
      try {
        await rootBundle.load(key);
        return key;
      } catch (_) {
        // Try the next extension.
      }
    }
    return null;
  }

  // Flower arch inside the medallion: (left, top, width) as fractions,
  // following the oval frame so no bloom is lost to the rounded corners.
  static const List<({double left, double top, double width})> _arch = [
    (left: 0.10, top: 0.140, width: 0.16),
    (left: 0.26, top: 0.055, width: 0.15),
    (left: 0.425, top: 0.030, width: 0.16),
    (left: 0.60, top: 0.055, width: 0.15),
    (left: 0.74, top: 0.130, width: 0.17),
  ];

  @override
  Widget build(BuildContext context) {
    final width = height * 0.82;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF8EF), Color(0xFFF3E7D3)],
        ),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<String?>(
              future: _coupleAsset ??= _resolveCoupleAsset(),
              builder: (context, snapshot) {
                final asset = snapshot.data;
                if (asset == null) {
                  return const CustomPaint(
                      painter: CoupleSilhouettePainter());
                }
                return Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.26,
                    bottom: height * 0.08,
                    left: width * 0.05,
                    right: width * 0.05,
                  ),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    // Tint the silhouette to the wedding burgundy.
                    color: CoupleSilhouettePainter.silhouetteColor,
                    colorBlendMode: BlendMode.srcIn,
                    filterQuality: FilterQuality.medium,
                  ),
                );
              },
            ),
            for (var i = 0; i < _arch.length; i++)
              Positioned(
                left: width * _arch[i].left,
                top: height * _arch[i].top,
                width: width * _arch[i].width,
                child: Image.asset(
                  'assets/flowers/flower${i + 1}.webp',
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The couple silhouette itself. All coordinates are fractions of the canvas
/// (w = width, h = height ≈ 1.22·w), tuned for the medallion frame.
class CoupleSilhouettePainter extends CustomPainter {
  const CoupleSilhouettePainter();

  /// Deep burgundy used for the figures; also used to tint the
  /// user-provided silhouette image.
  static const Color silhouetteColor = Color(0xFF4A0A20);
  static const Color _ink = silhouetteColor;
  static const Color _gold = Color(0xFFC9A24B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ink = Paint()..color = _ink;

    // Soft radial glow behind the couple.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.55),
      w * 0.40,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _gold.withValues(alpha: 0.20),
            _gold.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.55), radius: w * 0.40),
        ),
    );

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.865),
        width: w * 0.46,
        height: h * 0.022,
      ),
      Paint()..color = _ink.withValues(alpha: 0.16),
    );

    _paintGroom(canvas, w, h, ink);
    _paintBride(canvas, w, h, ink);

    // Clasped hands.
    canvas.drawCircle(Offset(w * 0.500, h * 0.510), w * 0.016, ink);

    // Little gold hearts drifting up from the joined hands.
    _heart(canvas, Offset(w * 0.500, h * 0.455), w * 0.014,
        _gold.withValues(alpha: 0.95));
    _heart(canvas, Offset(w * 0.520, h * 0.415), w * 0.010,
        _gold.withValues(alpha: 0.65));
    _heart(canvas, Offset(w * 0.488, h * 0.383), w * 0.0075,
        _gold.withValues(alpha: 0.40));
  }

  void _paintGroom(Canvas canvas, double w, double h, Paint ink) {
    // Head.
    canvas.drawCircle(Offset(w * 0.355, h * 0.315), w * 0.048, ink);

    // Turban.
    final turban = Path()
      ..moveTo(w * 0.305, h * 0.310)
      ..quadraticBezierTo(w * 0.315, h * 0.252, w * 0.360, h * 0.248)
      ..quadraticBezierTo(w * 0.402, h * 0.252, w * 0.406, h * 0.308)
      ..quadraticBezierTo(w * 0.355, h * 0.290, w * 0.305, h * 0.310)
      ..close();
    canvas.drawPath(turban, ink);
    // Gold turban band + turra plume.
    canvas.drawLine(
      Offset(w * 0.312, h * 0.301),
      Offset(w * 0.400, h * 0.299),
      Paint()
        ..color = _gold
        ..strokeWidth = w * 0.007
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(w * 0.396, h * 0.244), w * 0.010,
        Paint()..color = _gold);
    canvas.drawLine(
      Offset(w * 0.396, h * 0.252),
      Offset(w * 0.394, h * 0.270),
      Paint()
        ..color = _gold
        ..strokeWidth = w * 0.005,
    );

    // Sherwani: rounded shoulders, gentle waist, flared knee-length hem.
    final body = Path()
      ..moveTo(w * 0.355, h * 0.362)
      ..quadraticBezierTo(w * 0.302, h * 0.372, w * 0.297, h * 0.402)
      ..cubicTo(w * 0.290, h * 0.455, w * 0.294, h * 0.510, w * 0.292,
          h * 0.560)
      ..quadraticBezierTo(w * 0.288, h * 0.630, w * 0.293, h * 0.668)
      ..lineTo(w * 0.430, h * 0.668)
      ..quadraticBezierTo(w * 0.436, h * 0.600, w * 0.430, h * 0.535)
      ..cubicTo(w * 0.426, h * 0.475, w * 0.424, h * 0.432, w * 0.420,
          h * 0.408)
      ..quadraticBezierTo(w * 0.423, h * 0.385, w * 0.403, h * 0.382)
      ..close();
    canvas.drawPath(body, ink);
    // Gold button line down the sherwani front.
    canvas.drawLine(
      Offset(w * 0.408, h * 0.405),
      Offset(w * 0.412, h * 0.560),
      Paint()
        ..color = _gold.withValues(alpha: 0.85)
        ..strokeWidth = w * 0.004,
    );

    // Arm reaching to the bride.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.405, h * 0.400)
        ..quadraticBezierTo(w * 0.470, h * 0.442, w * 0.494, h * 0.505),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.030
        ..strokeCap = StrokeCap.round,
    );

    // Trousers.
    canvas.drawRect(
        Rect.fromLTRB(w * 0.322, h * 0.668, w * 0.352, h * 0.830), ink);
    canvas.drawRect(
        Rect.fromLTRB(w * 0.376, h * 0.668, w * 0.406, h * 0.830), ink);

    // Khussa shoes, toes curling towards the bride.
    for (final x in [0.316, 0.370]) {
      canvas.drawOval(
          Rect.fromLTRB(w * x, h * 0.824, w * (x + 0.052), h * 0.842), ink);
      canvas.drawCircle(
          Offset(w * (x + 0.052), h * 0.827), w * 0.007, ink);
    }
  }

  void _paintBride(Canvas canvas, double w, double h, Paint ink) {
    // Head.
    canvas.drawCircle(Offset(w * 0.615, h * 0.335), w * 0.043, ink);
    // Gold tikka on the forehead.
    canvas.drawCircle(Offset(w * 0.583, h * 0.320), w * 0.007,
        Paint()..color = _gold);

    // Dupatta: a wide veil sweeping over the head and down her back,
    // merging into the lehenga.
    final dupatta = Path()
      ..moveTo(w * 0.582, h * 0.312)
      ..quadraticBezierTo(w * 0.615, h * 0.262, w * 0.660, h * 0.292)
      ..quadraticBezierTo(w * 0.724, h * 0.345, w * 0.744, h * 0.455)
      ..quadraticBezierTo(w * 0.758, h * 0.565, w * 0.738, h * 0.660)
      ..quadraticBezierTo(w * 0.706, h * 0.555, w * 0.688, h * 0.465)
      ..quadraticBezierTo(w * 0.664, h * 0.352, w * 0.582, h * 0.312)
      ..close();
    canvas.drawPath(dupatta, ink);
    // Gold edge along the veil.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.660, h * 0.292)
        ..quadraticBezierTo(w * 0.724, h * 0.345, w * 0.744, h * 0.455)
        ..quadraticBezierTo(w * 0.758, h * 0.565, w * 0.738, h * 0.660),
      Paint()
        ..color = _gold.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.005,
    );

    // Bodice.
    final bodice = Path()
      ..moveTo(w * 0.615, h * 0.375)
      ..lineTo(w * 0.578, h * 0.396)
      ..quadraticBezierTo(w * 0.568, h * 0.442, w * 0.585, h * 0.492)
      ..lineTo(w * 0.648, h * 0.492)
      ..quadraticBezierTo(w * 0.662, h * 0.442, w * 0.652, h * 0.396)
      ..close();
    canvas.drawPath(bodice, ink);

    // Arm reaching to the groom.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.582, h * 0.412)
        ..quadraticBezierTo(w * 0.530, h * 0.450, w * 0.508, h * 0.505),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.026
        ..strokeCap = StrokeCap.round,
    );

    // Lehenga: smooth A-line flare with a softly scalloped hem.
    final lehenga = Path()
      ..moveTo(w * 0.583, h * 0.486)
      ..cubicTo(w * 0.545, h * 0.60, w * 0.515, h * 0.72, w * 0.505,
          h * 0.830)
      ..quadraticBezierTo(w * 0.545, h * 0.846, w * 0.585, h * 0.836)
      ..quadraticBezierTo(w * 0.630, h * 0.850, w * 0.672, h * 0.836)
      ..quadraticBezierTo(w * 0.716, h * 0.848, w * 0.755, h * 0.830)
      ..cubicTo(w * 0.748, h * 0.71, w * 0.718, h * 0.60, w * 0.652,
          h * 0.486)
      ..close();
    canvas.drawPath(lehenga, ink);
    // Gold hemline following the scallops.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.510, h * 0.816)
        ..quadraticBezierTo(w * 0.548, h * 0.831, w * 0.586, h * 0.821)
        ..quadraticBezierTo(w * 0.630, h * 0.835, w * 0.671, h * 0.821)
        ..quadraticBezierTo(w * 0.713, h * 0.833, w * 0.750, h * 0.816),
      Paint()
        ..color = _gold.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );
  }

  void _heart(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.3, c.dx - r * 0.7, c.dy - r * 1.4,
          c.dx, c.dy - r * 0.5)
      ..cubicTo(c.dx + r * 0.7, c.dy - r * 1.4, c.dx + r * 1.6, c.dy - r * 0.3,
          c.dx, c.dy + r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

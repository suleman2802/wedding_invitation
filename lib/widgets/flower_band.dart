import 'package:flutter/material.dart';

import 'gentle_float.dart';

/// The overlapping row of five flower images used along section edges:
/// assets/flowers/flower1.webp … flower5.webp, laid out left to right with
/// the smaller blooms building up to one large bloom on the right.
/// Each bloom drifts and rocks gently, out of phase with its neighbours.
class FlowerBand extends StatelessWidget {
  final double height;
  const FlowerBand({super.key, this.height = 170});

  // Left-to-right placement: (left, width, lift) as fractions of the band
  // width/height, mirroring the reference sizes 163/164/178/216/310 px.
  static const List<({double left, double width, double lift})> _slots = [
    (left: 0.00, width: 0.20, lift: 0.02),
    (left: 0.145, width: 0.20, lift: -0.02),
    (left: 0.30, width: 0.225, lift: 0.03),
    (left: 0.465, width: 0.265, lift: -0.01),
    (left: 0.63, width: 0.37, lift: 0.06),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < _slots.length; i++)
                  Positioned(
                    left: w * _slots[i].left,
                    bottom: height * _slots[i].lift,
                    width: w * _slots[i].width,
                    child: GentleFloat(
                      dy: 4.0 + i % 3,
                      angle: 0.02,
                      period: Duration(milliseconds: 4200 + i * 620),
                      phase: i * 0.19,
                      child: Image.asset(
                        'assets/flowers/flower${i + 1}.webp',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

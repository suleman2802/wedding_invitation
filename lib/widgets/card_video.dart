import 'package:flutter/material.dart';

import 'card_video_stub.dart'
    if (dart.library.js_interop) 'card_video_web.dart' as impl;

/// The animated invitation card (assets/invitation/invitation_card.mp4),
/// rendered as a chromeless inline video so it reads as a page animation.
/// It sits paused on its first frame until [play] is called — done when the
/// envelope opens — then plays once and holds on the finished card.
class CardVideo extends StatelessWidget {
  const CardVideo({super.key});

  /// Starts the card animation from the beginning. Safe to call once the
  /// widget has been built; muted videos may be played programmatically.
  static void play() => impl.playCardVideo();

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: impl.buildCardVideo());
  }
}

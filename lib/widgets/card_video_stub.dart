import 'package:flutter/material.dart';

/// Non-web fallback: a plain cream panel (the animated card video is only
/// available in the web build — see card_video_web.dart).
Widget buildCardVideo() {
  return Container(
    color: const Color(0xFFFBF4EA),
    alignment: Alignment.center,
    child: const Icon(Icons.movie_outlined,
        size: 42, color: Color(0xFF8C7B6B)),
  );
}

void playCardVideo() {}

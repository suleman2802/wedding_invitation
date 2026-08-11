import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

web.HTMLAudioElement? _element;

/// Plays (or resumes) the looping background track via a browser audio
/// element. Must be called from a user gesture the first time, so the
/// browser's autoplay policy allows it.
void audioPlay(String assetKey) {
  final element = _element ??=
      (web.document.createElement('audio') as web.HTMLAudioElement
        ..src = ui_web.assetManager.getAssetUrl(assetKey)
        ..loop = true
        ..volume = 0.35);
  element.play();
}

void audioPause() {
  _element?.pause();
}

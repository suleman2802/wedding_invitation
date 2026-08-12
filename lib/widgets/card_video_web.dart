import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

const _viewType = 'invitation-card-video';
web.HTMLVideoElement? _element;
bool _registered = false;

/// Web implementation: a chromeless, muted, inline HTML video — no controls,
/// no pointer events — so it reads as a page animation, not an embedded
/// player. Created paused; [playCardVideo] starts it from the beginning.
Widget buildCardVideo() {
  if (!_registered) {
    _registered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final v = web.document.createElement('video') as web.HTMLVideoElement;
      v.src = ui_web.assetManager
          .getAssetUrl('assets/invitation/invitation_card.mp4');
      v.muted = true;
      v.setAttribute('muted', '');
      v.setAttribute('playsinline', '');
      v.preload = 'auto';
      v.controls = false;
      v.loop = false;
      v.style.cssText =
          'width:100%;height:100%;object-fit:cover;pointer-events:none;'
          'background:#FBF4EA;';
      _element = v;
      return v;
    });
  }
  return const HtmlElementView(viewType: _viewType);
}

void playCardVideo() {
  final v = _element;
  if (v == null) return;
  v.currentTime = 0;
  v.play();
}

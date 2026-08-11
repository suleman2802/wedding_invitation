import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_impl_stub.dart'
    if (dart.library.js_interop) 'audio_impl_web.dart' as impl;

/// Background-music controller for the invitation.
///
/// Looks for assets/audio/music.mp3 (or .m4a / .ogg). [start] is called from
/// the envelope's tap handler — a user gesture, which satisfies the browser
/// autoplay policy — and the floating button toggles play/pause afterwards.
class WeddingAudio {
  WeddingAudio._();

  /// Whether music is currently playing (drives the floating button icon).
  static final ValueNotifier<bool> playing = ValueNotifier(false);

  static Future<bool>? _availableFuture;
  static String? _assetKey;
  static bool _hasTrack = false;

  /// Resolves whether a music file is bundled. Called during preload so the
  /// answer is already known by the time the envelope is tapped.
  static Future<bool> available() => _availableFuture ??= _resolve();

  static Future<bool> _resolve() async {
    for (final name in ['music.mp3', 'music.m4a', 'music.ogg']) {
      final key = 'assets/audio/$name';
      try {
        await rootBundle.load(key);
        _assetKey = key;
        _hasTrack = true;
        return true;
      } catch (_) {
        // Try the next extension.
      }
    }
    return false;
  }

  /// Starts the music if a track exists. Safe to call multiple times.
  /// Must be invoked synchronously from a user gesture the first time.
  static void start() {
    if (!_hasTrack || playing.value) return;
    impl.audioPlay(_assetKey!);
    playing.value = true;
  }

  static void toggle() {
    if (playing.value) {
      impl.audioPause();
      playing.value = false;
    } else {
      start();
    }
  }
}

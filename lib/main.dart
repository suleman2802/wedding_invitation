import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/wedding_audio.dart';
import 'screens/envelope_screen.dart';
import 'screens/invitation_page.dart';
import 'theme.dart';
import 'wedding_config.dart';
import 'widgets/envelope_unseal.dart';

void main() {
  runApp(const WeddingInvitationApp());
}

class WeddingInvitationApp extends StatelessWidget {
  const WeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${WeddingConfig.groomShort}'s Wedding Invitation",
      debugShowCheckedModeBanner: false,
      theme: buildWeddingTheme(),
      home: const _Root(),
    );
  }
}

/// Invitation page with the envelope overlay on top; the overlay removes
/// itself once its opening animation completes. A loading veil covers
/// everything until the photos and fonts are fully downloaded and decoded,
/// so the first thing a guest sees is complete and in place.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _opened = false;
  bool _ready = false;
  bool _veilGone = false;
  bool _preloadStarted = false;

  static const List<String> _criticalImages = [
    'assets/grandparents/grandfather_new_image.png',
    'assets/flowers/flower1.webp',
    'assets/flowers/flower2.webp',
    'assets/flowers/flower3.webp',
    'assets/flowers/flower4.webp',
    'assets/flowers/flower5.webp',
    'assets/couple/couple.png',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_preloadStarted) {
      _preloadStarted = true;
      _preload();
    }
  }

  Future<void> _preload() async {
    // Kick off the font downloads used across the site.
    WeddingType.script();
    WeddingType.serif();
    WeddingType.display();
    WeddingType.caps();
    WeddingType.arabic();

    final loads = <Future<void>>[
      for (final asset in _criticalImages)
        precacheImage(AssetImage(asset), context, onError: (_, __) {}),
      GoogleFonts.pendingFonts().then<void>((_) {}).catchError((_) {}),
      // Resolve whether a music track is bundled, so the envelope tap can
      // start it synchronously within the gesture.
      WeddingAudio.available().then<void>((_) {}),
    ];

    try {
      await Future.wait([
        // Give the curtain a graceful moment even on instant loads…
        Future<void>.delayed(const Duration(milliseconds: 1600)),
        // …and never hold guests hostage on a slow network.
        Future.wait(loads)
            .timeout(const Duration(seconds: 12), onTimeout: () => const []),
      ]);
    } catch (_) {
      // Whatever failed to load will simply stream in after the veil lifts.
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const InvitationPage(),
        if (!_opened)
          EnvelopeOverlay(
            onOpened: () => setState(() => _opened = true),
          ),
        if (!_veilGone)
          EnvelopeUnseal(
            ready: _ready,
            onOpened: () => setState(() => _veilGone = true),
          ),
      ],
    );
  }
}

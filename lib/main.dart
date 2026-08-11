import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/wedding_audio.dart';
import 'screens/envelope_screen.dart';
import 'screens/invitation_page.dart';
import 'theme.dart';
import 'wedding_config.dart';
import 'widgets/gentle_float.dart';

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
        // Never flash the veil for just a few frames…
        Future<void>.delayed(const Duration(milliseconds: 900)),
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
          IgnorePointer(
            ignoring: _ready,
            child: AnimatedOpacity(
              opacity: _ready ? 0 : 1,
              duration: const Duration(milliseconds: 650),
              onEnd: () {
                if (_ready) setState(() => _veilGone = true);
              },
              child: const _LoadingVeil(),
            ),
          ),
      ],
    );
  }
}

/// Full-screen loading state shown while assets download: the couple's seal,
/// a soft tagline and a slim spinner on the wedding burgundy.
class _LoadingVeil extends StatelessWidget {
  const _LoadingVeil();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GentleFloat(
              dy: 0,
              scale: 0.06,
              period: const Duration(seconds: 3),
              child: Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WeddingColors.deepBurgundy,
                  border: Border.all(
                    color: WeddingColors.gold.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      WeddingConfig.sealMonogram,
                      maxLines: 1,
                      softWrap: false,
                      style: WeddingType.script(
                          size: 26, color: WeddingColors.softCream),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Something beautiful is on its way…',
              textAlign: TextAlign.center,
              style: WeddingType.script(
                  size: 27, color: WeddingColors.softCream),
            ),
            const SizedBox(height: 10),
            Text(
              'THE WEDDING OF '
              '${WeddingConfig.groomShort.toUpperCase()} & '
              '${WeddingConfig.brideShort.toUpperCase()}',
              textAlign: TextAlign.center,
              style: WeddingType.caps(
                size: 11,
                color: WeddingColors.gold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WeddingColors.softCream.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

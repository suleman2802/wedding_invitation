import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import 'map_embed_stub.dart'
    if (dart.library.js_interop) 'map_embed_web.dart' as embed;

/// A framed Google Maps preview of the venue.
///
/// While the embed loads, a burgundy loading panel with a spinner is shown.
/// The panel sits BEHIND the map iframe: the iframe itself stays transparent
/// until its content has painted and then fades in over the panel (handled in
/// map_embed_web.dart), so the loading state is always visible regardless of
/// how the browser composites iframes. The preview is static; tapping
/// anywhere opens the full map link.
class MapPreview extends StatefulWidget {
  final String query;
  final String? openUrl;
  final double height;

  const MapPreview({
    super.key,
    required this.query,
    this.openUrl,
    this.height = 240,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  /// Once true the veil (hidden behind the opaque map by then) is removed
  /// from the tree so its spinner stops animating.
  bool _veilDismissed = false;
  Timer? _dismissTimer;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Safety net: drop the veil after 14s no matter what.
    _fallbackTimer = Timer(const Duration(seconds: 14), _scheduleDismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  /// Called when the iframe has loaded and its fade-in has been scheduled
  /// (0.9s grace + 0.7s fade). Keep the veil around until the fade is over.
  void _scheduleDismiss() {
    if (!mounted || _veilDismissed || _dismissTimer != null) return;
    _dismissTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _veilDismissed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.openUrl == null
          ? null
          : () => launchUrl(Uri.parse(widget.openUrl!),
              mode: LaunchMode.externalApplication),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: WeddingColors.gold.withValues(alpha: 0.65),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Loading panel BEHIND the transparent iframe.
              if (!_veilDismissed)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        WeddingColors.burgundy,
                        WeddingColors.deepBurgundy,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: WeddingColors.cream,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LOADING MAP…',
                        style: WeddingType.caps(
                          size: 11,
                          color: WeddingColors.gold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              embed.buildMapEmbed(widget.query, onLoad: _scheduleDismiss),
            ],
          ),
        ),
      ),
    );
  }
}

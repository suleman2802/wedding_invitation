import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredViews = {};

/// Current load listener per view type. Looked up at event time so the most
/// recently built widget gets notified even after rebuilds.
final Map<String, void Function()> _loadListeners = {};

/// Web implementation: renders the keyless Google Maps embed in an iframe.
///
/// The iframe starts fully transparent — the Flutter loading veil painted
/// behind it shows through — and fades in only after its content has loaded
/// (plus a short grace period so the map tiles have actually painted).
/// Pointer events are disabled so the page keeps scrolling normally and taps
/// reach the Flutter layer that opens the full map. [onLoad] notifies the
/// Flutter side once the fade-in has been scheduled.
Widget buildMapEmbed(String query, {void Function()? onLoad}) {
  final viewType = 'google-map-embed-${query.hashCode}';
  if (onLoad != null) {
    _loadListeners[viewType] = onLoad;
  }
  if (_registeredViews.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src =
          'https://maps.google.com/maps?q=${Uri.encodeComponent(query)}&z=15&output=embed';
      iframe.style.cssText = 'border:0;width:100%;height:100%;'
          'pointer-events:none;opacity:0;transition:opacity 0.7s ease;';
      final reveal = (() {
        iframe.style.opacity = '1';
        _loadListeners[viewType]?.call();
      }).toJS;
      iframe.addEventListener(
        'load',
        ((web.Event _) {
          // Give the map tiles a moment to paint before fading in.
          web.window.setTimeout(reveal, 900.toJS);
        }).toJS,
      );
      // Safety net: reveal after 12s even if the load event never fires.
      web.window.setTimeout(reveal, 12000.toJS);
      return iframe;
    });
  }
  return HtmlElementView(viewType: viewType);
}

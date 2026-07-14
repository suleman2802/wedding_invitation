import 'package:flutter/material.dart';

/// Non-web fallback: a simple placeholder panel (the real embedded map is
/// only available in the web build — see map_embed_web.dart).
Widget buildMapEmbed(String query, {void Function()? onLoad}) {
  if (onLoad != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }
  return Container(
    color: const Color(0xFFE8E0D2),
    alignment: Alignment.center,
    child: const Icon(Icons.map_outlined, size: 42, color: Color(0xFF8C7B6B)),
  );
}

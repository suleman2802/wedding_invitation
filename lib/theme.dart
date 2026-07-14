import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour palette for the whole invitation.
class WeddingColors {
  static const Color burgundy = Color(0xFF61102E);
  static const Color deepBurgundy = Color(0xFF490A21);
  static const Color darkestBurgundy = Color(0xFF35061A);
  static const Color cream = Color(0xFFFBF4EA);
  static const Color softCream = Color(0xFFF3E8D8);
  static const Color gold = Color(0xFFC9A24B);
  static const Color blush = Color(0xFFE7C9C4);
  static const Color inkOnCream = Color(0xFF3C2530);
}

/// Text styles. Script for headings, serif for body — loaded via Google Fonts.
class WeddingType {
  static TextStyle script({
    double size = 40,
    Color color = Colors.white,
    List<Shadow>? shadows,
  }) =>
      GoogleFonts.greatVibes(
        fontSize: size,
        color: color,
        shadows: shadows,
      );

  static TextStyle serif({
    double size = 17,
    Color color = WeddingColors.inkOnCream,
    FontWeight weight = FontWeight.w500,
    double height = 1.55,
    double letterSpacing = 0.2,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle display({
    double size = 28,
    Color color = WeddingColors.inkOnCream,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 1.0,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  /// Arabic calligraphy style, used for the Bismillah.
  static TextStyle arabic({
    double size = 22,
    Color color = WeddingColors.gold,
    List<Shadow>? shadows,
  }) =>
      GoogleFonts.amiri(
        fontSize: size,
        color: color,
        height: 1.9,
        shadows: shadows,
      );

  /// Small, widely letter-spaced caps used for labels like "DAYS".
  static TextStyle caps({
    double size = 12,
    Color color = WeddingColors.inkOnCream,
    double letterSpacing = 3.0,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
      );
}

ThemeData buildWeddingTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: WeddingColors.darkestBurgundy,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WeddingColors.burgundy,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.cormorantGaramondTextTheme(),
  );
}

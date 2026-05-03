import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colours ──────────────────────────────────────────────────────────
const kGreen900  = Color(0xFF1B5E20);
const kGreen800  = Color(0xFF2E7D32);
const kGreen600  = Color(0xFF43A047);
const kGreen400  = Color(0xFF66BB6A);
const kGreen200  = Color(0xFFA5D6A7);
const kDarkBg    = Color(0xFF0F1117);
const kDarkSurf  = Color(0xFF181C27);
const kDarkSurf2 = Color(0xFF1E2336);

abstract class AppTheme {
  // ── Light ──────────────────────────────────────────────────────────────
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: kGreen800,
      brightness: Brightness.light,
      primary:       kGreen800,
      onPrimary:     Colors.white,
      secondary:     kGreen600,
      surface:       Colors.white,
      surfaceContainerHighest: const Color(0xFFE8F5E9),
      error:         const Color(0xFFC62828),
    );
    return _base(cs, Brightness.light);
  }

  // ── Dark ───────────────────────────────────────────────────────────────
  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: kGreen400,
      brightness: Brightness.dark,
      primary:       kGreen400,
      onPrimary:     Colors.black,
      secondary:     kGreen200,
      surface:       kDarkSurf,
      surfaceContainerHighest: kDarkSurf2,
      error:         const Color(0xFFEF9A9A),
    );
    return _base(cs, Brightness.dark);
  }

  static ThemeData _base(ColorScheme cs, Brightness brightness) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge:  GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w800),
      displaySmall:  GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w800),
      headlineMedium:GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w700),
      titleLarge:    GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3:     true,
      colorScheme:      cs,
      brightness:       brightness,
      textTheme:        textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF1F5F2)
          : kDarkBg,

      // Cards — MD elevation level 1
      cardTheme: CardThemeData(
        elevation:    2,
        shadowColor:  brightness == Brightness.light
            ? Colors.black26
            : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surface,
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  cs.primary,
          foregroundColor:  cs.onPrimary,
          elevation:        3,
          shadowColor:      cs.primary.withValues(alpha: 0.4),
          padding:          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Navigation rail / bottom bar
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor:      cs.surface,
        indicatorColor:       cs.primary.withValues(alpha: 0.15),
        selectedIconTheme:    IconThemeData(color: cs.primary),
        unselectedIconTheme:  const IconThemeData(color: Colors.grey),
        selectedLabelTextStyle: GoogleFonts.spaceGrotesk(
            color: cs.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: GoogleFonts.spaceGrotesk(color: Colors.grey),
        elevation: 4,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:  cs.surface,
        indicatorColor:   cs.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary);
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),

      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor:   cs.primary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
      ),
    );
  }
}

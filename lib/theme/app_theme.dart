import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neutrals
  static const Color vaultInk = Color(0xFF0A0C0E);
  static const Color vaultSurface = Color(0xFF14171A);
  static const Color vaultSurfaceLight = Color(0xFF1C2024);
  static const Color vaultBorder = Color(0xFF2A2E32);
  static const Color vaultBorderStrong = Color(0xFF3A3F44);

  // Light theme neutrals
  static const Color vaultMist = Color(0xFFF7F3EA);
  static const Color vaultSurfaceCream = Color(0xFFFFFEFB);
  static const Color vaultFog = Color(0xFFD7E0E7);
  static const Color vaultBorderLight = Color(0xFFE2D9C6);
  static const Color vaultInkMutedLight = Color(0xFF8C8474);

  // Accents
  static const Color vaultBeige = Color(0xFFD6B27F);
  static const Color vaultBeigeMuted = Color(0xFF956960);
  static const Color vaultGold = Color(0xFFC9A06C);
  static const Color vaultGoldMuted = Color(0xFFA97F49);

  static const Color vaultOnDark = Color(0xFFF7FBFD);
  static const Color vaultInkMuted = Color(0xFF8A9099);

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return GoogleFonts.manropeTextTheme(base).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark ? vaultOnDark : vaultInk,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark ? vaultOnDark : vaultInk,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark ? vaultBeige : vaultGoldMuted,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark ? vaultOnDark : vaultInk,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark ? vaultOnDark : vaultInk,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: brightness == Brightness.dark ? vaultFog : vaultInk,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 12,
        color: brightness == Brightness.dark ? vaultFog : vaultInk,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: vaultMist,
    colorScheme: const ColorScheme.light(
      primary: vaultGoldMuted,
      secondary: vaultGold,
      tertiary: vaultBeige,
      surface: vaultSurfaceCream,
      onPrimary: vaultOnDark,
      onSecondary: vaultInk,
      onSurface: vaultInk,
      outline: vaultBorderLight,
    ),
    dividerTheme: const DividerThemeData(
      color: vaultBorderLight,
      thickness: 1,
      space: 1,
    ),
    textTheme: _textTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: vaultMist,
      foregroundColor: vaultInk,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: vaultGoldMuted,
      ),
    ),
    cardTheme: CardThemeData(
      color: vaultSurfaceCream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: vaultBorderLight, width: 1),
      ),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: vaultSurfaceCream,
      hintStyle: GoogleFonts.manrope(color: vaultInkMutedLight, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultBorderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultBorderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultGoldMuted, width: 1.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: vaultSurfaceCream,
        foregroundColor: vaultInk,
        side: const BorderSide(color: vaultBorderLight, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    iconTheme: const IconThemeData(color: vaultGoldMuted),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vaultInk,
        foregroundColor: vaultOnDark,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: vaultGoldMuted,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: vaultMist,
      selectedItemColor: vaultGoldMuted,
      unselectedItemColor: vaultInkMutedLight,
      elevation: 0,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: vaultGoldMuted,
      textColor: vaultInk,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: vaultInk,
    colorScheme: const ColorScheme.dark(
      primary: vaultBeige,
      secondary: vaultGold,
      tertiary: vaultBeigeMuted,
      surface: vaultSurface,
      onPrimary: vaultInk,
      onSecondary: vaultInk,
      onSurface: vaultOnDark,
      outline: vaultBorder,
    ),
    dividerTheme: const DividerThemeData(
      color: vaultBorder,
      thickness: 1,
      space: 1,
    ),
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      backgroundColor: vaultInk,
      foregroundColor: vaultOnDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: vaultBeige,
      ),
    ),
    cardTheme: CardThemeData(
      color: vaultSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: vaultBorder, width: 1),
      ),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: vaultSurface,
      hintStyle: GoogleFonts.manrope(color: vaultInkMuted, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vaultBeige, width: 1.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: vaultSurface,
        foregroundColor: vaultOnDark,
        side: const BorderSide(color: vaultBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    iconTheme: const IconThemeData(color: vaultBeige),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vaultBeige,
        foregroundColor: vaultInk,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: vaultBeige,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: vaultInk,
      selectedItemColor: vaultBeige,
      unselectedItemColor: vaultInkMuted,
      elevation: 0,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: vaultBeige,
      textColor: vaultOnDark,
    ),
  );
}

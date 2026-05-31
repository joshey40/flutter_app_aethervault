import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color vaultInk = Color(0xFF07111A);
  static const Color vaultSurface = Color(0xFF11202D);
  static const Color vaultSurfaceLight = Color(0xFF1A2D3B);
  static const Color vaultMist = Color(0xFFF4F1EA);
  static const Color vaultFog = Color(0xFFD7E0E7);
  static const Color vaultAmber = Color(0xFFD79334);
  static const Color vaultBeige = Color(0xFFE6C79C);
  static const Color vaultGold = Color(0xFFC69C6D);
  static const Color vaultOnDark = Color(0xFFF7FBFD);
  static const Color vaultInkMuted = Color(0xFF8EA3B5);

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
        color: brightness == Brightness.dark ? vaultOnDark : vaultInk,
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
        fontSize: 14,
        color: brightness == Brightness.dark ? vaultFog : vaultInk,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: vaultMist,
    colorScheme: const ColorScheme.light(
      primary: vaultAmber,
      secondary: vaultBeige,
      tertiary: vaultGold,
      surface: Colors.white,
      onPrimary: vaultInk,
      onSecondary: vaultInk,
      onSurface: vaultInk,
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
        color: vaultInk,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.black12,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultFog),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultFog),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultAmber, width: 2),
      ),
    ),
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
        foregroundColor: vaultAmber,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: vaultAmber,
      unselectedItemColor: vaultInkMuted,
      elevation: 12,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: vaultAmber,
      textColor: vaultInk,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: vaultInk,
    colorScheme: const ColorScheme.dark(
      primary: vaultAmber,
      secondary: vaultBeige,
      tertiary: vaultGold,
      surface: vaultSurface,
      onPrimary: vaultInk,
      onSecondary: vaultInk,
      onSurface: vaultOnDark,
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
        color: vaultOnDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: vaultSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.black45,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: vaultSurfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultSurfaceLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultSurfaceLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vaultAmber, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vaultAmber,
        foregroundColor: vaultInk,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: vaultGold,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: vaultSurface,
      selectedItemColor: vaultAmber,
      unselectedItemColor: vaultInkMuted,
      elevation: 12,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: vaultAmber,
      textColor: vaultOnDark,
    ),
  );
}

ThemeData buildAetherVaultTheme(Brightness brightness) =>
    brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

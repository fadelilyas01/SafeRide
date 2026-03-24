import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: isDark ? AppColors.darkBackground : AppColors.surface,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      textTheme: _buildTextTheme(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 12,
          shadowColor: colorScheme.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w900, 
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        hoverColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
        ),
        labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final Color textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
      displaySmall: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
      titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
      titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: textColor, height: 1.5),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: textColor.withValues(alpha: 0.7), height: 1.4),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
    );
  }
}

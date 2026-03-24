import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Premium Midnight & Neon
  static const Color primary = Color(0xFF6366F1); // Radiant Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Electric Purple
  static const Color accent = Color(0xFF00D4AA); // Spearmint
  static const Color alert = Color(0xFFF43F5E); // Rose Red
  
  // Surfaces Light
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFE2E8F0);
  
  // Surfaces Dark - Deep Space
  static const Color darkBackground = Color(0xFF0B1120); 
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155); 

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnDark = Color(0xFFF8FAF7);
  
  // Utils
  static const Color grey = Color(0xFFCBD5E1);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBg = Color(0x0FFFFFFF);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient radiantGradient = LinearGradient(
    colors: [primary, secondary, Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

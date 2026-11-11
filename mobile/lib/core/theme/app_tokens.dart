import 'package:flutter/material.dart';

/// Design Tokens SafeRide Mobile — Grille 8pt et Palette OLED True Dark
abstract final class AppTokens {
  // Palette OLED True Dark
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceInset = Color(0xFF0D1322);
  static const Color border = Color(0xFF1E293B);
  static const Color borderActive = Color(0xFF334155);
  static const Color borderFocus = Color(0xFF6366F1);

  // Couleurs Sémantiques & Accents
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryMuted = Color(0x296366F1);
  static const Color success = Color(0xFF10B981);
  static const Color successMuted = Color(0x2910B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerMuted = Color(0x29EF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x29F59E0B);

  // Typographie & Hiérarchie Textuelle
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color white = Color(0xFFFFFFFF);

  // Grille 8pt (Rayons)
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Grille 8pt (Espacements)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // Cible Tactile Minimale (Loi de Fitts)
  static const double minTouchTarget = 48.0;
}


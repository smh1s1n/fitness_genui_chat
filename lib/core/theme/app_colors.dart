import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradients & Accents
  static const Color primaryStart = Color(0xFF6366F1); // Violet 500
  static const Color primaryEnd = Color(0xFF4F46E5);   // Indigo 600
  static const Color secondaryStart = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryEnd = Color(0xFF0D9488);   // Teal 600

  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentEmerald = Color(0xFF10B981); // Emerald 500
  static const Color accentOrange = Color(0xFFF97316); // Orange 500
  static const Color accentRose = Color(0xFFF43F5E); // Rose 500

  // Background and Surfaces (Dark Theme First)
  static const Color background = Color(0xFF0B0F19);   // Deep Navy Slate
  static const Color surface = Color(0xFF111827);      // Charcoal Grey
  static const Color surfaceCard = Color(0xFF1E293B);  // Slate Card
  static const Color border = Color(0xFF334155);       // Slate Border

  // Glassmorphism overlays
  static const Color glassWhite = Color(0x0AFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);  // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B);     // Slate 500

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondaryStart, secondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient activeGradient = LinearGradient(
    colors: [primaryStart, secondaryStart],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGlassGradient = LinearGradient(
    colors: [Color(0x1F1E293B), Color(0x0F0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

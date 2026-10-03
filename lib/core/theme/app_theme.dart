import 'package:flutter/material.dart';

class AppTheme {
  static const seed = Color(0xFF3B82F6);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0B0F19),
        indicatorColor: scheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF141B2D),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

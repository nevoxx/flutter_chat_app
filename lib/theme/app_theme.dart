import 'package:flutter/material.dart';

/// App theme configuration inspired by Discord-like chat interfaces
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Dark theme colors (Discord-inspired)
  static const _darkBackground = Color(0xFF36393F);
  static const _darkSurface = Color(0xFF2F3136);
  static const _darkSurfaceVariant = Color(0xFF202225);
  static const _darkPrimary = Color(0xFF5865F2);
  static const _darkOnPrimary = Colors.white;
  static const _darkOnSurface = Color(0xFFDCDDDE);
  static const _darkOnSurfaceVariant = Color(0xFF96989D);
  static const _darkDivider = Color(0xFF1E1F22);

  // Light theme colors (clean and modern)
  static const _lightBackground = Color(0xFFFFFFFF);
  static const _lightSurface = Color(0xFFF2F3F5);
  static const _lightSurfaceVariant = Color(0xFFE3E5E8);
  static const _lightPrimary = Color(0xFF5865F2);
  static const _lightOnPrimary = Colors.white;
  static const _lightOnSurface = Color(0xFF2E3338);
  static const _lightOnSurfaceVariant = Color(0xFF5E6772);
  static const _lightDivider = Color(0xFFE3E5E8);

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        onSurfaceVariant: _darkOnSurfaceVariant,
        error: Color(0xFFED4245),
        onError: Colors.white,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _darkOnSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        hintStyle: const TextStyle(
          color: _darkOnSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _darkOnSurfaceVariant,
        ),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        selectedTileColor: Color(0xFF404249),
        selectedColor: _darkOnSurface,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _darkOnSurface),
        displayMedium: TextStyle(color: _darkOnSurface),
        displaySmall: TextStyle(color: _darkOnSurface),
        headlineLarge: TextStyle(color: _darkOnSurface),
        headlineMedium: TextStyle(color: _darkOnSurface),
        headlineSmall: TextStyle(color: _darkOnSurface),
        titleLarge: TextStyle(color: _darkOnSurface),
        titleMedium: TextStyle(color: _darkOnSurface),
        titleSmall: TextStyle(color: _darkOnSurface),
        bodyLarge: TextStyle(color: _darkOnSurface),
        bodyMedium: TextStyle(color: _darkOnSurface),
        bodySmall: TextStyle(color: _darkOnSurfaceVariant),
        labelLarge: TextStyle(color: _darkOnSurface),
        labelMedium: TextStyle(color: _darkOnSurface),
        labelSmall: TextStyle(color: _darkOnSurfaceVariant),
      ),
    );
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        surfaceContainerHighest: _lightSurfaceVariant,
        onSurfaceVariant: _lightOnSurfaceVariant,
        error: Color(0xFFED4245),
        onError: Colors.white,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _lightOnSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        hintStyle: const TextStyle(
          color: _lightOnSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _lightOnSurfaceVariant,
        ),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        selectedTileColor: Color(0xFFE3E5E8),
        selectedColor: _lightOnSurface,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _lightOnSurface),
        displayMedium: TextStyle(color: _lightOnSurface),
        displaySmall: TextStyle(color: _lightOnSurface),
        headlineLarge: TextStyle(color: _lightOnSurface),
        headlineMedium: TextStyle(color: _lightOnSurface),
        headlineSmall: TextStyle(color: _lightOnSurface),
        titleLarge: TextStyle(color: _lightOnSurface),
        titleMedium: TextStyle(color: _lightOnSurface),
        titleSmall: TextStyle(color: _lightOnSurface),
        bodyLarge: TextStyle(color: _lightOnSurface),
        bodyMedium: TextStyle(color: _lightOnSurface),
        bodySmall: TextStyle(color: _lightOnSurfaceVariant),
        labelLarge: TextStyle(color: _lightOnSurface),
        labelMedium: TextStyle(color: _lightOnSurface),
        labelSmall: TextStyle(color: _lightOnSurfaceVariant),
      ),
    );
  }
}


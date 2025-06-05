import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF4F8FF7);
  static const _backgroundColor = Color(0xFF0D1B2A);
  static const _surfaceColor = Color(0xFF1B2635);
  static const _surfaceVariantColor = Color(0xFF2A3441);
  static const _onSurfaceColor = Color(0xFFE6E6E6);
  static const _onSurfaceVariantColor = Color(0xFFB3B3B3);
  static const _borderColor = Color(0xFF3A4552);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        surface: _backgroundColor,
        surfaceContainer: _surfaceColor,
        surfaceContainerHighest: _surfaceVariantColor,
        onSurface: _onSurfaceColor,
        onSurfaceVariant: _onSurfaceVariantColor,
        outline: _borderColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _onSurfaceColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: _surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _onSurfaceColor,
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariantColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariantColor),
        hintStyle: const TextStyle(color: _onSurfaceVariantColor),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primaryColor,
        unselectedLabelColor: _onSurfaceVariantColor,
        indicatorColor: _primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      dividerTheme: const DividerThemeData(
        color: _borderColor,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _onSurfaceColor,
        iconColor: _onSurfaceVariantColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: _onSurfaceColor,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: _onSurfaceColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: _onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          color: _onSurfaceColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: _onSurfaceColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _onSurfaceVariantColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: _onSurfaceColor,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: _onSurfaceVariantColor,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: _onSurfaceColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _onSurfaceVariantColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: _onSurfaceVariantColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Custom colors for specific use cases
class AppColors {
  static const primary = Color(0xFF4F8FF7);
  static const secondary = Color(0xFF7C4DFF);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  static const background = Color(0xFF0D1B2A);
  static const surface = Color(0xFF1B2635);
  static const surfaceVariant = Color(0xFF2A3441);
  static const onSurface = Color(0xFFE6E6E6);
  static const onSurfaceVariant = Color(0xFFB3B3B3);
  static const border = Color(0xFF3A4552);

  static const uploadZoneBorder = Color(0xFF4F8FF7);
  static const uploadZoneBackground = Color(0xFF1A2332);
}

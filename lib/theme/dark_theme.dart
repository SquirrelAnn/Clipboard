import 'package:flutter/material.dart';

import 'darkcolors.dart';

class CustomDarkTheme {
  static const Color _surface = Color(0xFF2B2B2B);
  static const Color _surfaceHigh = Color(0xFF383838);
  static const Color _surfaceLow = Color(0xFF1E1E1E);
  static const Color _onSurface = Color(0xFFF2F2F2);
  static const Color _onSurfaceMuted = Color(0xFFB8B8B8);
  static const Color _outline = Color(0xFF707070);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: DarkCustomColors.btnHighlighted,
      onPrimary: Colors.white,
      secondary: DarkCustomColors.btnHovered,
      onSecondary: Colors.white,
      surface: _surface,
      onSurface: _onSurface,
      surfaceContainerHighest: _surfaceHigh,
      surfaceContainerLow: _surfaceLow,
      outline: _outline,
      error: DarkCustomColors.red,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceLow,
      cardColor: _surfaceHigh,
      canvasColor: _surfaceHigh,
      iconTheme: const IconThemeData(color: _onSurface),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceHigh,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: _onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: _onSurface,
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: _onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: _onSurface),
        bodySmall: TextStyle(fontSize: 12, color: _onSurfaceMuted),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLow,
        hintStyle: const TextStyle(color: _onSurfaceMuted),
        labelStyle: const TextStyle(color: _onSurfaceMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: DarkCustomColors.btnHighlighted, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            if (states.contains(WidgetState.disabled)) {
              return _onSurfaceMuted.withValues(alpha: 0.5);
            }
            return _onSurfaceMuted;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return DarkCustomColors.btnHighlighted;
            }
            if (states.contains(WidgetState.disabled)) {
              return _surfaceLow;
            }
            return _surface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: DarkCustomColors.btnHighlighted);
            }
            return const BorderSide(color: _outline);
          }),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return _onSurfaceMuted;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _onSurface,
          side: const BorderSide(color: _outline),
          backgroundColor: _surface,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(_onSurface),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return _surface;
            }
            return _surfaceHigh;
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DarkCustomColors.btnHighlighted,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: DarkCustomColors.btnHighlighted,
      ),
      dividerTheme: DividerThemeData(
        color: DarkCustomColors.btnHighlighted,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceHigh,
        contentTextStyle: const TextStyle(color: _onSurface),
        actionTextColor: DarkCustomColors.btnHighlighted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceHigh,
        foregroundColor: _onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkCustomColors.btnHighlighted;
          }
          return _surfaceHigh;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}

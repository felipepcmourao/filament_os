import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

class MyTheme {
  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFff6a1a),
    onPrimary: Color(0xFF121316),
    secondary: Color(0xFFe85a0f),
    onSecondary: Color(0xFF121316),
    error: Color(0xFFef4444),
    onError: Color(0xFF121316),
    surface: Color(0xFF121316),
    onSurface: Color(0xFFFFFFFF),
    outline: Color(0xFFFFFFFF),
  );

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFe85a0f),
    onPrimary: Color(0xFF121316),
    secondary: Color(0xFFff6a1a),
    onSecondary: Color(0xFF121316),
    error: Color(0xFFdc2626),
    onError: Color(0xFFffffff),
    surface: Color(0xFFf8f9fa),
    onSurface: Color(0xFF121316),
    outline: Color(0xFF121316),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: darkColorScheme,
      extensions: [AppColors.dark],
      textTheme: AppTextTheme.textTheme.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: lightColorScheme,
      extensions: [AppColors.light],
      textTheme: AppTextTheme.textTheme.apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),
    );
  }
}

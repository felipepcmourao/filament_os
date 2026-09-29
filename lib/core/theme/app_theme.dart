import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

/// Onde os tokens viram `ThemeData` — o que o `MaterialApp` de fato consome.
///
/// **Os dois `ColorScheme` são escritos à mão de propósito: não troque por
/// `ColorScheme.fromSeed`.** Ver ADR 0003.
///
/// O `textTheme` passa por `apply` porque o `google_fonts` traz cor própria:
/// sem ele, o texto ignoraria o `onSurface` e ficaria preto no tema escuro.
///
/// `get` e não `final`: remontar o `ThemeData` custa pouco, porque o
/// `MaterialApp` o lê uma vez por rebuild dele, não por frame.
class AppTheme {
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

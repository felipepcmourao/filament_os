import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

/// Onde os tokens viram `ThemeData` — o que o `MaterialApp` de fato consome.
///
/// **Os dois `ColorScheme` são escritos à mão de propósito, não por descuido:
/// não troque por `ColorScheme.fromSeed` (ver [ADR 0003](../../../docs/adr/0003-design-system.md)).**
/// O `fromSeed` gera uma paleta inteira a partir de uma cor semente pelo
/// algoritmo do Material 3 — resolve o contraste sozinho, mas devolve tons que
/// ninguém escolheu, e o laranja da marca sai da máquina diferente do que
/// entrou. Aqui a identidade visual vem antes da conveniência. O custo é
/// assumir a responsabilidade pelo contraste, já que não há mais algoritmo
/// nenhum garantindo isso.
///
/// Só os papéis que o app realmente usa estão preenchidos — o `ColorScheme`
/// aceita muito mais campos, e os que faltam caem no padrão do Material.
/// Mesmo raciocínio de "domínio enxuto": token só existe quando algo usa.
///
/// `extensions: [AppColors.x]` é o que pluga as cores de domínio no tema (ver
/// `AppColors`). E o `textTheme` passa por `.apply(bodyColor:/displayColor:)`
/// porque as fontes vêm do `google_fonts` com a cor padrão dele — sem esse
/// `apply`, o texto ignoraria o `onSurface` e ficaria preto no tema escuro.
///
/// São `get` em vez de `final`: cada acesso remonta o `ThemeData`. Não há
/// problema porque o `MaterialApp` lê isso uma vez por rebuild dele, não por
/// frame — e o `ThemeData` é imutável, então nada de estado se perde.
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

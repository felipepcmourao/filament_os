import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A escala tipográfica do app: duas fontes, com papéis separados.
///
/// **Space Grotesk** nos tamanhos grandes (`display`, `headline`, `title`) e
/// **Inter** nos pequenos (`body`, `label`). A divisão é deliberada e segue o
/// que cada fonte faz bem: a Space Grotesk é geométrica e tem personalidade
/// nos cortes das letras — aparece em título, some em texto corrido; a Inter
/// foi desenhada pra tela em corpo pequeno, onde legibilidade importa mais que
/// caráter. Usar uma só nos dois papéis sacrificaria um dos dois lados.
///
/// O `TextTheme` abaixo é montado campo a campo justamente por isso: os dois
/// `TextTheme` completos do `google_fonts` acima existem só como fonte de
/// onde tirar os estilos: `display` só entrega os grandes, `body` só os
/// pequenos, e o resultado é um terceiro `TextTheme` misto. Não dá pra fazer
/// isso com um `copyWith`, daí a listagem explícita.
///
/// Nenhum tamanho ou peso é redefinido aqui — as métricas são as do Material,
/// só a família muda. E nenhuma cor: quem aplica é o `AppTheme`, com o
/// `onSurface` de cada tema (ver `AppTheme`), pra que o mesmo `TextTheme`
/// sirva ao tema claro e ao escuro.
class AppTextTheme {
  static final display = GoogleFonts.spaceGroteskTextTheme();
  static final body = GoogleFonts.interTextTheme();

  static final textTheme = TextTheme(
    displayLarge: display.displayLarge,
    displayMedium: display.displayMedium,
    displaySmall: display.displaySmall,
    headlineLarge: display.headlineLarge,
    headlineMedium: display.headlineMedium,
    headlineSmall: display.headlineSmall,
    titleLarge: display.titleLarge,
    titleMedium: display.titleMedium,
    titleSmall: display.titleSmall,
    bodyLarge: body.bodyLarge,
    bodyMedium: body.bodyMedium,
    bodySmall: body.bodySmall,
    labelLarge: body.labelLarge,
    labelMedium: body.labelMedium,
    labelSmall: body.labelSmall,
  );
}

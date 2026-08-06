import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:flutter/material.dart';

/// Cor visível de cada `FilamentColor`.
///
/// Devolve a paleta bruta do Material (`Colors.blue`, `Colors.yellow`), e não
/// tokens do `AppColors`, **de propósito** — é a exceção deliberada à regra
/// "nunca use valor de cor direto no widget".
///
/// A razão: aqui a cor não é uma decisão visual, é um dado do produto. O
/// plástico na bobina é amarelo no mundo físico, e continua amarelo com o
/// app no tema claro ou escuro. Um token que se adapta ao brightness estaria
/// mentindo sobre o material — é o oposto do que `StockStatusMaterial` faz,
/// onde a cor É decisão visual e por isso vem do design system.
///
/// O custo dessa escolha é não controlar o contraste: `Colors.yellow` sobre
/// a `surface` clara quase desaparece. A saída não é distorcer o dado, e sim
/// dar contraste em volta dele — o swatch da lista de filamentos usa uma
/// borda em `colorScheme.outline` para isso. E, como reforço independente de
/// cor, o nome do filamento também aparece escrito (ver `FilamentColorLabel`),
/// então quem não distingue cores não depende deste swatch.
extension FilamentColorMaterial on FilamentColor {
  Color toMaterial() {
    switch (this) {
      case FilamentColor.blue:
        return Colors.blue;
      case FilamentColor.green:
        return Colors.green;
      case FilamentColor.grey:
        return Colors.grey;
      case FilamentColor.pink:
        return Colors.pink;
      case FilamentColor.red:
        return Colors.red;
      case FilamentColor.yellow:
        return Colors.yellow;
    }
  }
}

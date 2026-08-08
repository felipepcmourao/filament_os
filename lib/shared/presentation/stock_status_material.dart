import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/shared/domain/stock_status.dart';
import 'package:flutter/material.dart';

/// Cores de cada nível de estoque, vindas do design system.
///
/// Gêmeo do `StockStatusLabel`, no arquivo ao lado, que responde "que texto
/// isto mostra" enquanto este responde "que cor isto tem".
///
/// Aqui a cor **é** decisão visual — o oposto de `FilamentColorMaterial`, onde
/// a cor é dado do produto e por isso vem da paleta bruta do Material. Estoque
/// baixo não é amarelo no mundo físico: é amarelo porque o design system
/// decidiu que alerta é amarelo, e essa decisão muda com o tema. Daí os tokens
/// de `AppColors` em vez de `Colors.amber`.
///
/// Devolve um Record com o par `content`/`container` (e não dois getters
/// separados) porque os dois nunca são usados sozinhos: quem desenha um badge
/// precisa do fundo e do texto ao mesmo tempo, e são justamente os dois que
/// precisam ter contraste entre si. Separá-los abriria espaço pra alguém pegar
/// o fundo de um status e o texto de outro.
///
/// Recebe o `AppColors` por parâmetro em vez de ler o `Theme` sozinho porque
/// uma `extension` não tem `BuildContext` — quem chama já tem, e faz
/// `Theme.of(context).extension<AppColors>()`. Isso também mantém a extension
/// testável sem precisar montar um widget em volta.
extension StockStatusMaterial on StockStatus {
  ({Color content, Color container}) toMaterial(AppColors colors) {
    switch (this) {
      case StockStatus.exhausted:
        return (
          container: colors.exhaustedStockContainer,
          content: colors.exhaustedStock,
        );
      case StockStatus.low:
        return (container: colors.lowStockContainer, content: colors.lowStock);
      case StockStatus.healthy:
        return (
          container: colors.healthyStockContainer,
          content: colors.healthyStock,
        );
    }
  }
}

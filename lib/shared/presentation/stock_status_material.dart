import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/shared/domain/stock_status.dart';
import 'package:flutter/material.dart';

/// Cores de cada nível de estoque, vindas dos tokens de `AppColors` e não da
/// paleta do Material, porque aqui a cor é decisão visual. Ver ADR 0003.
///
/// Devolve fundo e texto num Record porque um badge usa os dois juntos, e
/// separá-los permitiria misturar o fundo de um status com o texto de outro.
///
/// Recebe `AppColors` por parâmetro porque extension não tem `BuildContext`,
/// o que também a deixa testável sem montar widget.
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

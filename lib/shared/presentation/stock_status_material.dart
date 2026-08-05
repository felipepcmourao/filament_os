import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/shared/domain/stock_status.dart';
import 'package:flutter/material.dart';

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

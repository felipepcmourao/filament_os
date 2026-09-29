import 'package:filament_os/shared/domain/stock_status.dart';

/// Nome exibido de cada nível de estoque.
extension StockStatusLabel on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.low:
        return 'Baixo';
      case StockStatus.healthy:
        return 'Saudável';
      case StockStatus.exhausted:
        return 'Esgotado';
    }
  }
}

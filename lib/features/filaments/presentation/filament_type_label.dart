import 'package:filament_os/features/filaments/domain/filament_type.dart';

/// Nome exibido de cada tipo de filamento.
///
/// Mesmo padrão de `FilamentColorLabel`, inclusive para 'PLA' e 'PETG', que
/// são designações técnicas e não seriam traduzidas. Ver `FilamentType`: a
/// regra "`domain/` não carrega string de exibição" vale sem exceção.
extension FilamentTypeLabel on FilamentType {
  String get label {
    switch (this) {
      case FilamentType.abs:
        return 'ABS';
      case FilamentType.petg:
        return 'PETG';
      case FilamentType.pla:
        return 'PLA';
      case FilamentType.plaMatte:
        return 'PLA Matte';
      case FilamentType.plaSilk:
        return 'PLA Silk';
      case FilamentType.tpu:
        return 'TPU';
    }
  }
}

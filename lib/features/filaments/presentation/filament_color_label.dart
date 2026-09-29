import 'package:filament_os/features/filaments/domain/filament_color.dart';

/// Nome exibido de cada cor de filamento.
extension FilamentColorLabel on FilamentColor {
  String get label {
    switch (this) {
      case FilamentColor.blue:
        return 'Azul';
      case FilamentColor.green:
        return 'Verde';
      case FilamentColor.grey:
        return 'Cinza';
      case FilamentColor.pink:
        return 'Rosa';
      case FilamentColor.red:
        return 'Vermelho';
      case FilamentColor.yellow:
        return 'Amarelo';
    }
  }
}

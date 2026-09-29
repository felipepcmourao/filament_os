import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:flutter/material.dart';

/// Cor visível de cada `FilamentColor`.
///
/// Vem da paleta bruta do Material, e não de tokens, de propósito: cor de
/// filamento é dado do produto, não decisão visual. Ver ADR 0003.
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

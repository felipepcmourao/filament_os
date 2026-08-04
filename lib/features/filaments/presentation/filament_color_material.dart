import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:flutter/material.dart';

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

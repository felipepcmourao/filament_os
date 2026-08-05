import 'package:filament_os/shared/domain/weight.dart';

enum StockStatus {
  healthy('Saudável'),
  low('Baixo'),
  exhausted('Esgotado');

  final String label;

  const StockStatus(this.label);

  factory StockStatus.fromWeight(Weight weight) {
    if (weight.isZero) return StockStatus.exhausted;
    if (weight < Weight.fromGrams(weightInGrams: 100)) return StockStatus.low;
    return StockStatus.healthy;
  }

  @override
  String toString() {
    return label;
  }
}

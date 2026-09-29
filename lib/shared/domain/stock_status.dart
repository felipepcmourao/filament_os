import 'package:filament_os/shared/domain/weight.dart';

/// Nível de estoque de um filamento.
///
/// Derivado do peso, nunca armazenado no `Filament`, para que status e peso
/// não tenham como dessincronizar.
enum StockStatus {
  healthy,
  low,
  exhausted;

  /// O limiar de 100g é provisório: deveria ser configurável por filamento
  /// ou por usuário.
  factory StockStatus.fromWeight(Weight weight) {
    if (weight.isZero) return StockStatus.exhausted;
    if (weight < Weight.fromGrams(weightInGrams: 100)) return StockStatus.low;
    return StockStatus.healthy;
  }
}

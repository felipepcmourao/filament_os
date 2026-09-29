import 'package:filament_os/shared/domain/weight.dart';

/// Classificação do nível de estoque de um filamento.
///
/// Vive em `shared/domain`, e não em `filaments/`, porque a classificação é
/// reutilizável por outras features — o dashboard vai querer exatamente a
/// mesma noção de "estoque baixo" que a lista de filamentos usa. Mesmo
/// raciocínio que colocou `Money` e `Weight` aqui.
///
/// É derivado, não armazenado: nenhum `Filament` guarda o próprio status.
/// Ele é sempre recalculado a partir do peso atual via `fromWeight`, então
/// status e peso não têm como ficar dessincronizados.
///
/// Texto exibido em `StockStatusLabel` e cores em `StockStatusMaterial`,
/// ambos na presentation — o enum em si não conhece Flutter.
enum StockStatus {
  healthy,
  low,
  exhausted;

  /// O limiar de 100g está fixo no código e é provisório: o valor certo
  /// depende do caso (100g sobrando é pouco pra uma peça grande e muito pra
  /// várias pequenas), então deveria ser configurável. Vira campo do
  /// `Filament` — ou preferência do dono — quando essa feature existir.
  factory StockStatus.fromWeight(Weight weight) {
    if (weight.isZero) return StockStatus.exhausted;
    if (weight < Weight.fromGrams(weight: 100)) return StockStatus.low;
    return StockStatus.healthy;
  }
}

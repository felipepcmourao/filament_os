import 'package:filament_os/shared/domain/weight.dart';

/// Texto exibido de um peso. Ver ADR 0005.
///
/// 1. **Duas casas decimais**, o formato em que os slicers reportam consumo
///    de filamento, e não a precisão guardada (miligramas seriam três).
/// 2. **Sem `,00`** em grama inteira, para não exibir precisão que não existe.
/// 3. **Zero vira `'Sem estoque'`**, porque a `FilamentDetailsPage` mostra o
///    peso sem badge ao lado, e ali `-` ou `0 gramas` não diria nada.
extension WeightLabel on Weight {
  String get label {
    String weightLabel;
    if (isZero) {
      return 'Sem estoque';
    } else if (weightInMilligrams % 1000 == 0) {
      weightLabel = toGrams.toStringAsFixed(0);
    } else {
      weightLabel = toGrams.toStringAsFixed(2).replaceAll('.', ',');
    }
    return '$weightLabel gramas';
  }
}

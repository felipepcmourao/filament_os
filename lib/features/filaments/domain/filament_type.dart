/// Tipos/variações de material de filamento conhecidos.
///
/// Mesmo raciocínio do `FilamentColor`: vive em `filaments/domain` porque é
/// vocabulário específico do `Filament`, não um conceito cross-feature.
enum FilamentType {
  pla('PLA'),
  plaSilk('PLA Silk'),
  plaMatte('PLA Matte'),
  petg('PETG'),
  tpu('TPU'),
  abs('ABS');

  final String label;
  const FilamentType(this.label);

  @override
  String toString() => label;
}

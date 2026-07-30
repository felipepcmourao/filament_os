/// Tipos/variações de material de filamento conhecidos.
///
/// Mesmo raciocínio do `FilamentColor`: vive em `filaments/domain` porque é
/// vocabulário específico do `Filament`, não um conceito cross-feature.
enum FilamentType { pla, plaSilk, plaMatte, petg, tpu, abs }

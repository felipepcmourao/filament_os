/// Tipos/variações de material de filamento conhecidos.
///
/// Mesmo raciocínio do `FilamentColor`: vive em `filaments/domain` porque é
/// vocabulário específico do `Filament`, não um conceito cross-feature.
///
/// O nome exibido ('PLA Silk') fica em `FilamentTypeLabel`, na presentation,
/// mesmo sendo designação técnica que não seria traduzida em idioma nenhum.
/// A regra adotada é uma só, sem exceção a julgar caso a caso: `domain/` não
/// carrega string de exibição. Uma regra sem ressalva é mais fácil de seguir
/// — e de revisar — do que uma que exige decidir a cada enum novo.
enum FilamentType { pla, plaSilk, plaMatte, petg, tpu, abs }

/// Estados possíveis de uma impressão (`Print`).
///
/// Fica em `prints/domain` (não em `shared/domain`) pelo mesmo motivo de
/// `FilamentColor`/`FilamentType`: é vocabulário específico do `Print`, não
/// um conceito compartilhado entre features.
///
/// Texto exibido em `PrintStatusLabel`, na presentation. Lá os três labels
/// são substantivos ('Falha', não 'Falhou') porque nomeiam o estado em que a
/// impressão está — não o evento que a levou até ele.
enum PrintStatus { printing, successful, fail }

/// Cores conhecidas de filamento.
///
/// Fica em `filaments/domain` (não em `shared/domain`, como `Money`/`Weight`)
/// porque só o `Filament` usa esse conceito — não é compartilhado entre
/// features. Adicionar uma cor nova é só acrescentar um valor aqui.
enum FilamentColor { red, yellow, golden, silver, green, blue }

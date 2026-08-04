/// Cores conhecidas de filamento.
///
/// Fica em `filaments/domain` (não em `shared/domain`, como `Money`/`Weight`)
/// porque só o `Filament` usa esse conceito — não é compartilhado entre
/// features. Adicionar uma cor nova é só acrescentar um valor aqui.
enum FilamentColor {
  red('Vermelho'),
  yellow('Amarelo'),
  grey('Cinza'),
  pink('Rosa'),
  green('Verde'),
  blue('Azul');

  final String label;

  const FilamentColor(this.label);

  @override
  String toString() => label;
}

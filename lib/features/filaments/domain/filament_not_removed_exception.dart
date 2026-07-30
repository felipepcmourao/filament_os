/// Erro lançado quando se pede pra remover um `Filament` cujo `id` não
/// existe no repositório.
///
/// Categoria diferente de `ArgumentError`: o `id` passado é uma `String`
/// válida em si — o problema é que a busca por ele não encontrou nada,
/// mesma ideia por trás do `CurrencyMismatchException` do `Money`.
class FilamentNotRemovedException implements Exception {
  final String id;

  FilamentNotRemovedException({required this.id});

  @override
  String toString() {
    return 'Não foi possível remover o filamento de ID: $id';
  }
}

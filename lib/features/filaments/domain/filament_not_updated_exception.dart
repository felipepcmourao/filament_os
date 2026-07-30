/// Erro lançado quando se pede pra atualizar (`update`) um `Filament` cujo
/// `id` não existe no repositório — mesma categoria do
/// `FilamentNotRemovedException`, só que pro caminho de atualização.
class FilamentNotUpdatedException implements Exception {
  final String id;

  FilamentNotUpdatedException({required this.id});

  @override
  String toString() {
    return 'Não foi possível atualizar o filamento de ID: $id';
  }
}

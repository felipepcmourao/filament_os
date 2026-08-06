/// Erro lançado quando se pede pra atualizar (`update`) um `Print` cujo `id`
/// não existe no repositório — o gêmeo do `FilamentNotUpdatedException`, do
/// outro lado do domínio.
///
/// É um tipo próprio, e não um `Exception()` genérico, pra que quem chama
/// possa tratar este caso especificamente (`on PrintNotUpdatedException`)
/// sem capturar junto qualquer outro erro que passe por ali. Carrega o `id`
/// pelo mesmo motivo: um log que diz apenas "Exception" não ajuda ninguém.
class PrintNotUpdatedException implements Exception {
  final String printId;

  PrintNotUpdatedException({required this.printId});

  @override
  String toString() {
    return 'Não foi possível atualizar a impressão de ID: $printId';
  }
}

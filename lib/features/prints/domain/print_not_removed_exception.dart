/// Erro lançado quando se pede pra remover (`remove`) um `Print` cujo `id`
/// não existe no repositório — mesma categoria do
/// `PrintNotUpdatedException`, só que pro caminho de remoção.
///
/// Existe porque `removeWhere` não avisa quando não removeu nada: sem esta
/// exceção, pedir a remoção de um id inexistente seria indistinguível de uma
/// remoção bem-sucedida.
class PrintNotRemovedException implements Exception {
  final String printId;

  PrintNotRemovedException({required this.printId});

  @override
  String toString() {
    return 'Não foi possível excluir a impressão de ID: $printId';
  }
}

/// Base selada de todas as exceções de domínio do app.
///
/// É `sealed` porque a `presentation` precisa traduzir exceção → texto de
/// tela num `switch` exaustivo, e o compilador só consegue provar que todos
/// os casos foram cobertos quando conhece a lista fechada de subtipos. É a
/// mesma garantia que as extensions `*Label` já têm sobre enum: exceção nova
/// sem texto quebra o build, não a tela do usuário.
///
/// O preço está à vista neste arquivo. Em Dart, `sealed` fecha a hierarquia
/// **por biblioteca**, e uma biblioteca é, por padrão, um arquivo — por isso
/// as exceções de `filaments` e de `prints` saíram de `features/*/domain/` e
/// passaram a morar juntas aqui, em `shared/`. As features deixaram de ser
/// donas das próprias exceções. Foi troca deliberada: a exaustividade em
/// tempo de compilação vale mais do que a posse, num domínio deste tamanho.
/// A alternativa descartada era uma `abstract class` comum, que preservava a
/// posse mas deixava passar exceção sem texto até o runtime.
///
/// Não carrega campo `message`. Texto de tela é decisão de apresentação e
/// mora na extension da `presentation`; para diagnóstico, cada subtipo já
/// tem o seu `toString()`.
sealed class AppException implements Exception {
  const AppException();
}

// ------------------------- FILAMENT EXCEPTION --------------------------------

/// Erro lançado quando um `filamentId` referenciado (ex: dentro de um
/// `FilamentUsage`, ao registrar uma impressão) não corresponde a nenhum
/// `Filament` existente. Mesma categoria de erro dos outros dois
/// `FilamentNot*Exception` — uma referência que não resolveu, não um
/// valor inválido em si.
class FilamentNotFoundException extends AppException {
  final String filamentId;

  FilamentNotFoundException({required this.filamentId});

  @override
  String toString() {
    return 'Filamento de ID $filamentId não foi encontrado';
  }
}

/// Erro lançado quando se pede pra remover um `Filament` cujo `id` não
/// existe no repositório.
///
/// Categoria diferente de `ArgumentError`: o `id` passado é uma `String`
/// válida em si — o problema é que a busca por ele não encontrou nada,
/// mesma ideia por trás do `CurrencyMismatchException` do `Money`.
class FilamentNotRemovedException extends AppException {
  final String id;

  FilamentNotRemovedException({required this.id});

  @override
  String toString() {
    return 'Não foi possível remover o filamento de ID: $id';
  }
}

/// Erro lançado quando se pede pra atualizar (`update`) um `Filament` cujo
/// `id` não existe no repositório — mesma categoria do
/// `FilamentNotRemovedException`, só que pro caminho de atualização.
class FilamentNotUpdatedException extends AppException {
  final String id;

  FilamentNotUpdatedException({required this.id});

  @override
  String toString() {
    return 'Não foi possível atualizar o filamento de ID: $id';
  }
}

// ------------------------- PRINT EXCEPTION --------------------------------

/// Erro lançado quando se pede pra remover (`remove`) um `Print` cujo `id`
/// não existe no repositório — mesma categoria do
/// `PrintNotUpdatedException`, só que pro caminho de remoção.
///
/// Existe porque `removeWhere` não avisa quando não removeu nada: sem esta
/// exceção, pedir a remoção de um id inexistente seria indistinguível de uma
/// remoção bem-sucedida.
class PrintNotRemovedException extends AppException {
  final String printId;

  PrintNotRemovedException({required this.printId});

  @override
  String toString() {
    return 'Não foi possível excluir a impressão de ID: $printId';
  }
}

/// Erro lançado quando se pede pra atualizar (`update`) um `Print` cujo `id`
/// não existe no repositório — o gêmeo do `FilamentNotUpdatedException`, do
/// outro lado do domínio.
///
/// É um tipo próprio, e não um `Exception()` genérico, pra que quem chama
/// possa tratar este caso especificamente (`on PrintNotUpdatedException`)
/// sem capturar junto qualquer outro erro que passe por ali. Carrega o `id`
/// pelo mesmo motivo: um log que diz apenas "Exception" não ajuda ninguém.
class PrintNotUpdatedException extends AppException {
  final String printId;

  PrintNotUpdatedException({required this.printId});

  @override
  String toString() {
    return 'Não foi possível atualizar a impressão de ID: $printId';
  }
}

// ------------------------- CURRENCY EXCEPTION --------------------------------

/// Erro lançado quando dois `Money` de moedas diferentes são combinados
/// (ex: somar BRL com EUR).
///
/// É uma exceção customizada, não um `ArgumentError` genérico, porque é uma
/// categoria de erro diferente: `ArgumentError` serve pra "esse valor,
/// sozinho, é inválido" (ex: peso negativo); aqui, os dois `Money` são cada
/// um válido por si só — o problema é que não podem ser combinados na
/// mesma operação. Separar os dois permite tratar cada categoria de forma
/// diferente em quem capturar o erro (`try`/`catch`) mais pra frente.
class CurrencyMismatchException extends AppException {
  final String expectedCurrency;
  final String actualCurrency;

  CurrencyMismatchException({
    required this.expectedCurrency,
    required this.actualCurrency,
  });

  // Sem isso, um erro não tratado apareceria no console só como
  // "Instance of 'CurrencyMismatchException'" — sem dizer qual moeda
  // era esperada e qual foi recebida.
  @override
  String toString() {
    return 'Moedas incompatíveis. Moeda esperada: $expectedCurrency. Moeda fornecida: $actualCurrency';
  }
}

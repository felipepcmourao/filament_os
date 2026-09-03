import 'package:filament_os/shared/domain/app_exception.dart';
import 'package:filament_os/shared/presentation/error_message_view.dart';

/// Traduz cada exceção de domínio no texto que o usuário lê na tela.
///
/// Existe porque `'Erro: $err'` interpolava o `toString()` da exceção direto
/// no `Text`, e `toString()` é ferramenta de diagnóstico: ele carrega id de
/// repositório, nome de classe Dart e vocabulário interno. Nada disso ajuda
/// quem está olhando a tela, e a partir da Sessão 7 o mesmo padrão passaria
/// a imprimir o `code` de uma `FirebaseAuthException` — `user-not-found`
/// renderizado é enumeração de usuários entregue de graça.
///
/// O `switch` é exaustivo e sem `default`, como os das extensions sobre
/// enum: é para isso que o `AppException` é `sealed`. Exceção nova sem texto
/// quebra a compilação, não a tela.
///
/// **Formato: descrever a falha e dizer o que fazer em seguida.** "Não foi
/// possível excluir o filamento" sozinho deixa o usuário parado; por isso as
/// cinco primeiras terminam em "tente novamente". Nenhuma delas afirma uma
/// causa que o app não tem como saber (do tipo "verifique sua conexão"), e
/// nenhuma carrega id — id é dado de log.
///
/// A `CurrencyMismatchException` é a exceção da regra, e vale entender por
/// quê: ela só é lançada quando o *código* soma moedas diferentes. Nenhuma
/// ação do usuário a provoca e nenhuma a resolve — repetir a operação
/// devolve o mesmo erro para sempre, então "tente novamente" ali seria
/// mentira. Ela recebe o mesmo `generalErrorMessage` das falhas que o
/// usuário não controla, que é o texto honesto para "quebrou aqui dentro".
extension AppExceptionLabel on AppException {
  String get label => switch (this) {
    FilamentNotFoundException() =>
      'O filamento não foi encontrado. Por favor, tente novamente',
    FilamentNotUpdatedException() =>
      'Não foi possível atualizar os dados do filamento. Por favor, tente novamente',
    FilamentNotRemovedException() =>
      'Não foi possível excluir o filamento. Por favor, tente novamente',
    PrintNotUpdatedException() =>
      'Não foi possível atualizar os dados da impressão. Por favor, tente novamente',
    PrintNotRemovedException() =>
      'Não foi possível excluir a impressão. Por favor, tente novamente',
    CurrencyMismatchException() => generalErrorMessage,
  };
}

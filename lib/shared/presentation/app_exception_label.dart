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
/// **Formato:** descreve a falha e diz o que fazer em seguida, sem afirmar
/// uma causa que o app não tem como saber e sem id, que é dado de log.
///
/// `CurrencyMismatchException` não diz "tente novamente": só um bug no código
/// a provoca, e repetir devolveria o mesmo erro para sempre.
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

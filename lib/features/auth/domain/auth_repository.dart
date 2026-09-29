import 'package:filament_os/features/auth/domain/app_user.dart';

/// Contrato de autenticação que o app conhece.
///
/// **O estado sai por um lugar só: `authStatus()`.** Não existe um
/// `currentUser` síncrono de propósito. Na abertura do app, com o usuário já
/// logado, o Firebase ainda está restaurando a sessão e um valor síncrono
/// responderia `null` — o guard mandaria para o login e, um instante depois,
/// de volta para a home: a tela de login piscando. Um valor só consegue
/// dizer `AppUser` ou `null`; não tem como dizer "ainda não sei".
///
/// Pelo mesmo motivo, **nenhuma operação devolve usuário.** Login e registro
/// terminam em `Future<void>`, e quem quer saber o resultado escuta o stream.
/// Devolver o usuário também criaria uma segunda fonte de verdade. Falha não é
/// `null` de retorno, é exceção: um `null` diria que falhou, mas não por quê.
///
/// Parâmetros nomeados porque e-mail e senha são ambos `String`: posicionais,
/// trocar a ordem compilaria sem aviso.
abstract class AuthRepository {
  /// Emite o usuário a cada mudança, e `null` quando não há ninguém logado.
  /// Antes do primeiro evento o estado é "ainda não sei", nunca `null`.
  Stream<AppUser?> authStatus();

  Future<void> signIn({required String email, required String password});

  /// Já deixa o usuário logado: o `authStatus()` emite, como num `signIn`.
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();

  /// **Termina igual exista ou não a conta**, para não revelar quais e-mails
  /// estão cadastrados: a implementação engole o "conta não encontrada".
  Future<void> resetPassword({required String email});
}

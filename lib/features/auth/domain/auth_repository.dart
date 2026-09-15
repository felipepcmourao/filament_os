import 'package:filament_os/features/auth/domain/app_user.dart';

/// Contrato de autenticação que o app conhece.
///
/// Mora no `domain/` e não importa `firebase_auth`: quem implementa com o
/// Firebase é o `data/`, e o resto do app — telas, roteador, outras features
/// via `di/` — só enxerga esta abstração e o `AppUser`. Trocar de provedor de
/// autenticação, ou testar sem o Firebase, é trocar a implementação, nunca
/// este arquivo.
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
/// `signIn(password, email)` compilaria sem aviso e mandaria a senha no lugar
/// do e-mail.
abstract class AuthRepository {
  /// Emite o usuário autenticado toda vez que o estado muda, e `null` quando
  /// não há ninguém logado.
  ///
  /// O terceiro estado — "ainda não sei" — não cabe em `AppUser?` e não está
  /// no tipo: ele é o intervalo **antes do primeiro evento**. Quem consome o
  /// stream precisa tratar essa espera como estado próprio, e não presumir
  /// `null` enquanto nada chegou. No Riverpod, é o `AsyncLoading`.
  Stream<AppUser?> authStatus();

  Future<void> signIn({required String email, required String password});
  /// Cria a conta e já deixa o usuário logado: o `authStatus()` emite o
  /// usuário novo, igual a um `signIn`. Por isso os dois têm o mesmo retorno.
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  /// Envia o e-mail de redefinição de senha.
  ///
  /// **Termina do mesmo jeito exista ou não uma conta com esse e-mail.** Se o
  /// resultado fosse diferente nos dois casos, quem chamasse o método poderia
  /// descobrir quais e-mails têm conta no serviço — enumeração de usuários.
  /// Implementações precisam engolir o "conta não encontrada" do provedor em
  /// vez de repassá-lo.
  Future<void> resetPassword({required String email});
}

/// Os caminhos de URL do app, lidos só pelo roteador. Ver ADR 0006.
///
/// `idSegm` deriva de `idParam` porque o mesmo nome aparece na rota, na
/// leitura de `pathParameters` e na navegação.
class AppPaths {
  static const String home = '/';
  static const String filaments = '/filaments';
  static const String prints = '/prints';
  static const String idParam = 'id';
  static const String idSegm = ':$idParam';
  static const String login = '/login';
}

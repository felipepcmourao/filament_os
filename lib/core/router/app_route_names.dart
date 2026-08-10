/// Os identificadores de destino usados para navegar.
///
/// Gêmeo do `AppPaths`, com público oposto: **esta classe é lida pelas telas**
/// e `AppPaths` só pelo `app_router.dart`.
///
/// Navegar por nome (`goNamed`) em vez de por path significa que uma tela
/// pede "me leve ao destino `filamentDetails`" sem saber que a URL é
/// `/filaments/<id>`. Trocar o formato do caminho vira mudança de uma linha
/// no roteador, sem tocar em widget nenhum. E, para rotas com parâmetro, o
/// `go_router` monta a URL a partir do mapa — ninguém concatena string na mão.
class AppRouteNames {
  static const String filamentDetails = 'filamentDetails';
  static const String prints = 'prints';
  static const String filaments = 'filaments';
  static const String home = 'home';
  static const String login = 'login';
}

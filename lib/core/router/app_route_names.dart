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

  /// Os três destinos da barra de navegação, **na ordem em que aparecem nela**.
  ///
  /// Guarda só nomes, não caminhos: o `ShellRouter` descobre onde está lendo
  /// `GoRouterState.of(context).topRoute?.name`, que devolve o nome da rota
  /// atual. Comparar nome com nome mantém `AppPaths` fora daqui — se esta
  /// classe importasse `AppPaths`, toda tela que a importa arrastaria os
  /// caminhos junto, desfazendo a regra documentada acima.
  ///
  /// A ordem é acoplada à lista `destinations` do `ShellRouter`: o índice 0
  /// daqui tem que ser o mesmo destino do índice 0 de lá. Nada no compilador
  /// verifica isso — quem verifica é o teste 'Clicar na Navigation Bar leva
  /// para a tela correta'. Trocar dois itens de lugar aqui deixa ele vermelho.
  static const List<String> navBarPages = [filaments, home, prints];
}

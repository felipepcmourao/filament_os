/// Os caminhos de URL do app.
///
/// Ficam em `core/`, e não dentro de cada feature, pelo mesmo motivo dos
/// design tokens: uma feature que precisasse do path de outra teria que
/// importá-la, e essa dependência entre features cresce em O(n²). Aqui todo
/// mundo aponta pro mesmo lugar e ninguém aponta pro vizinho. De quebra, ver
/// o espaço de URLs inteiro num arquivo só torna visível uma colisão de path
/// que estaria escondida se cada feature declarasse a sua.
///
/// **Esta classe é lida só pelo `app_router.dart`.** As telas navegam por
/// nome, via `AppRouteNames` — assim nenhuma tela conhece o formato da URL e
/// reorganizar os caminhos não toca em widget nenhum.
///
/// `idParam` guarda só o nome do parâmetro e `idSegm` é derivado dele. O
/// mesmo texto aparece em três lugares (a declaração da rota, a leitura em
/// `pathParameters` e o mapa da navegação), então ele existe uma vez só.
class AppPaths {
  static const String home = '/';
  static const String filaments = '/filaments';
  static const String prints = '/prints';
  static const String idParam = 'id';
  static const String idSegm = ':$idParam';
}

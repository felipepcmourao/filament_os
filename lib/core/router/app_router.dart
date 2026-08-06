import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/presentation/not_found_page.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
import 'package:filament_os/features/filaments/presentation/filament_details_page.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:filament_os/features/prints/presentation/prints_page.dart';
import 'package:go_router/go_router.dart';

/// Onde a aplicação é montada: o único arquivo que conhece todas as telas.
///
/// Isso pode parecer violar a regra "nenhuma feature importa a presentation
/// de outra", mas não viola — ele não é uma feature. É o papel que o
/// `main.dart` tinha antes: existe para conhecer todo mundo, justamente para
/// que as features não precisem se conhecer entre si.
///
/// `static final`, uma instância só. Fosse campo de instância, cada `build`
/// do `MyApp` criaria um `GoRouter` novo e jogaria fora a pilha de navegação,
/// o histórico e a posição atual do usuário.
class AppRouter {
  static final router = GoRouter(
    // Rede de segurança para URLs que não casam com nenhuma rota. Só pega
    // erro de roteamento: `/filaments/id-inexistente` NÃO passa por aqui,
    // porque casa com a rota `:id` — aquela ausência é tratada dentro da
    // `FilamentDetailsPage`, depois de consultar o repositório.
    //
    // Nada aqui dentro pode lançar. Este é o tratador de erros: se ele
    // quebrar, o app fecha justamente enquanto tentava explicar o problema.
    // Daí o `if` em vez de `state.error!` direto, e `toString()` em vez de
    // `toFilePath()` — este último lança quando a URI tem query string ou
    // fragmento, que é exatamente o tipo de URL torta que chega aqui.
    errorBuilder: (context, state) {
      final uri = state.uri.toString();
      String error;
      if (state.error == null) {
        error = 'Erro desconhecido.';
      } else {
        error = state.error!.message;
      }

      return NotFoundPage(uri: uri, error: error);
    },
    routes: [
      // Início, filamentos e impressões são irmãs de propósito: são áreas
      // paralelas do app, não telas empilhadas. A consequência é que `go`
      // entre elas não deixa botão de voltar — o que passa a fazer sentido
      // quando a barra de navegação persistente entrar.
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppPaths.filaments,
        builder: (context, state) => const FilamentsPage(),
        // O detalhe é FILHA de /filaments, e isso não é organização de
        // arquivo: `go` reconstrói a pilha a partir da árvore, então navegar
        // pro detalhe empilha a lista embaixo e o botão de voltar leva de
        // volta a ela sem uma linha de código pra isso.
        //
        // O path da filha é relativo (`:id`, sem barra na frente) — com barra
        // o go_router o trataria como caminho absoluto e o aninhamento não
        // aconteceria.
        routes: [
          GoRoute(
            path: AppPaths.idSegm,
            name: AppRouteNames.filamentDetails,
            // `!` é seguro: se o builder rodou, a rota casou, e uma rota só
            // casa quando o segmento do parâmetro está presente.
            builder: (context, state) {
              final id = state.pathParameters[AppPaths.idParam]!;
              return FilamentDetailsPage(id: id);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppPaths.prints,
        builder: (context, state) => const PrintsPage(),
      ),
    ],
  );
}

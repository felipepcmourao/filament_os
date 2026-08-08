import 'package:filament_os/core/presentation/shell_router.dart';
import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/presentation/not_found_page.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
import 'package:filament_os/features/filaments/presentation/filament_details_page.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:filament_os/features/prints/presentation/prints_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Onde a aplicação é montada: o único arquivo que conhece todas as telas.
///
/// Isso pode parecer violar a regra "nenhuma feature importa a presentation
/// de outra", mas não viola — ele não é uma feature. É o papel que o
/// `main.dart` tinha antes: existe para conhecer todo mundo, justamente para
/// que as features não precisem se conhecer entre si.
///
/// Expõe duas coisas, e a diferença entre elas é o ponto:
///
/// - `router` é **a** instância do app. `static final`, uma só: fosse campo de
///   instância, cada `build` do `MyApp` criaria um `GoRouter` novo e jogaria
///   fora a pilha de navegação, o histórico e a posição atual do usuário.
/// - `createRouter()` monta um `GoRouter` **novo** a cada chamada.
///
/// Parece contradição — o campo existe justamente pra não recriar o roteador —
/// mas produção e teste querem coisas opostas. Em produção, muitos rebuilds
/// precisam cair no mesmo roteador. Num teste, cada caso é um app do zero, e
/// compartilhar a instância significa herdar onde o teste anterior parou:
/// `static` é uma instância por isolate, e o `flutter test` roda o arquivo
/// inteiro num isolate só. Sem a fábrica, um teste que navegasse pra
/// `/filaments` deixaria o próximo começando lá, sem tocar em nada — mesma
/// armadilha da lista `static` que foi revertida no repositório fake.
///
/// Note que `router` **chama** `createRouter()` em vez de repetir a
/// configuração. É o que garante que só exista uma cópia das rotas: se cada um
/// tivesse a sua, uma rota nova entraria em uma e não na outra, e os testes
/// passariam validando um roteador que não é o que o usuário usa.
///
/// Não é a `factory` do Dart, e não poderia ser: aquela palavra-chave só
/// devolve a própria classe, e o que se fabrica aqui é um `GoRouter`, não um
/// `AppRouter`. Esta classe nunca é instanciada — é só o nome que agrupa os
/// dois membros estáticos.
class AppRouter {
  static GoRouter createRouter() {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppPaths.home,
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
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => ShellRouter(child: child),
          routes: [
            GoRoute(
              path: AppPaths.home,
              builder: (context, state) => const HomePage(),
              name: AppRouteNames.home,
            ),

            GoRoute(
              path: AppPaths.filaments,
              builder: (context, state) => const FilamentsPage(),
              name: AppRouteNames.filaments,
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
                  parentNavigatorKey: rootNavigatorKey,
                ),
              ],
            ),

            GoRoute(
              path: AppPaths.prints,
              builder: (context, state) => const PrintsPage(),
              name: AppRouteNames.prints,
            ),
          ],
        ),
        // Início, filamentos e impressões são irmãs de propósito: são áreas
        // paralelas do app, não telas empilhadas. A consequência é que `go`
        // entre elas não deixa botão de voltar — o que passa a fazer sentido
        // quando a barra de navegação persistente entrar.
      ],
    );
  }

  static final router = createRouter();
}

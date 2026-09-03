import 'package:filament_os/core/auth/auth_notifier.dart';
import 'package:filament_os/core/presentation/app_shell.dart';
import 'package:filament_os/core/presentation/login_page.dart';
import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/presentation/not_found_page.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
import 'package:filament_os/features/filaments/presentation/filament_details_page.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:filament_os/features/prints/presentation/prints_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// - `createRouter(ref)` monta um `GoRouter` **novo** a cada chamada — é o
///   que os testes usam, cada um com seu próprio `ProviderContainer`, pra não
///   herdar posição de navegação uns dos outros (mesma armadilha da lista
///   `static` que foi revertida no repositório fake).
/// - `routerProvider`, declarado fora da classe (top-level, como todo
///   provider deste projeto), é quem a produção usa. `Provider<GoRouter>`
///   computa `createRouter(ref)` uma vez só por container e guarda o
///   resultado — o mesmo mecanismo de cache que já protege
///   `filamentsRepositoryProvider` contra recriar o repositório a cada
///   rebuild, aplicado aqui pro roteador. Antes da Sessão 6, essa garantia
///   vinha de um campo `static final router` nesta classe; saiu quando o
///   `redirect` passou a depender de `ref` (roteador reativo a
///   `authProvider`), porque `static` não tem de onde pegar um `ref` de
///   dentro do `ProviderScope`.
///
/// `createRouter` continua `static` mesmo assim: não guarda estado nenhum
/// (recebe `ref` de fora), então não precisa de instância de `AppRouter` pra
/// existir. Não é a `factory` do Dart, e não poderia ser: aquela palavra-chave
/// só devolve a própria classe, e o que se fabrica aqui é um `GoRouter`, não
/// um `AppRouter`. Esta classe nunca é instanciada — é só o nome que agrupa a
/// fábrica.
class AppRouter {
  static GoRouter createRouter(Ref ref) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();
    final goRouterRefreshNotifier = GoRouterRefreshNotifier(ref);
    return GoRouter(
      redirect: (context, state) {
        final isLoggedIn = ref.read(authProvider);
        if (isLoggedIn) {
          return null;
        } else if (state.matchedLocation == AppPaths.login) {
          return null;
        } else {
          return AppPaths.login;
        }
      },
      refreshListenable: goRouterRefreshNotifier,
      navigatorKey: rootNavigatorKey,
      initialLocation: AppPaths.home,
      // Rede de segurança para URLs que não casam com nenhuma rota. Só pega
      // erro de roteamento: `/filaments/id-inexistente` NÃO passa por aqui,
      // porque casa com a rota `:id` — aquela ausência é tratada dentro da
      // `FilamentDetailsPage`, depois de consultar o repositório.
      //
      // Nada aqui dentro pode lançar. Este é o tratador de erros: se ele
      // quebrar, o app fecha justamente enquanto tentava explicar o problema.
      // Daí `toString()` em vez de `toFilePath()` — este último lança quando
      // a URI tem query string ou fragmento, que é exatamente o tipo de URL
      // torta que chega aqui.
      //
      // `state.error` existe e é ignorado de propósito: a mensagem dele vem
      // do go_router, em inglês e em vocabulário de biblioteca, e só repete
      // a URL que a `NotFoundPage` já mostra.
      errorBuilder: (context, state) {
        final uri = state.uri.toString();
        return NotFoundPage(uri: uri);
      },
      routes: [
        GoRoute(
          path: AppPaths.login,
          builder: (context, state) => const LoginPage(),
          name: AppRouteNames.login,
          redirect: (context, state) {
            final isLoggedIn = ref.read(authProvider);
            return isLoggedIn ? AppPaths.home : null;
          },
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => AppShell(child: child),
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
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.createRouter(ref));

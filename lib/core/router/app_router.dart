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

/// Onde a aplicação é montada: o único arquivo que conhece todas as telas, e
/// por isso não é uma feature. Ver ADR 0006.
///
/// `createRouter` fabrica um `GoRouter` novo a cada chamada, e é o que todo
/// teste deve usar; a produção usa o `routerProvider`. Ver ADR 0007.
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
      // Nada aqui pode lançar: daí `toString()`, e não `toFilePath()`, que
      // lança com query string ou fragmento, justo a URL torta que chega aqui.
      //
      // `state.error` é ignorado: vem do go_router, em inglês, e só repete a
      // URL que a `NotFoundPage` já mostra.
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
              // Path relativo, sem barra na frente: com barra o go_router o
              // trata como absoluto e o aninhamento some. Ver ADR 0006.
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

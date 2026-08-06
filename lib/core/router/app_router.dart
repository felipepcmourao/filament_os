import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
import 'package:filament_os/features/filaments/presentation/filament_details_page.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:filament_os/features/prints/presentation/prints_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppPaths.filaments,
        builder: (context, state) => const FilamentsPage(),
        routes: [
          GoRoute(
            path: AppPaths.idSegm,
            name: AppRouteNames.filamentDetails,
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

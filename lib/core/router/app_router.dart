import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/features/dashboard/presentation/home_page.dart';
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
      ),
      GoRoute(
        path: AppPaths.prints,
        builder: (context, state) => const PrintsPage(),
      ),
    ],
  );
}

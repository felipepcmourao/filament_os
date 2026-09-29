import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/presentation/nav_bar_options.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A moldura que fica em volta das três áreas do app.
///
/// São dois `Scaffold` aninhados, de propósito: este segura o que persiste (a
/// barra), e o de cada tela segura o que é dela (a `AppBar`, o `body`).
///
/// A aba acesa é derivada da URL a cada build, nunca guardada. Ver ADR 0006.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Compara nome com nome para este widget não precisar conhecer `AppPaths`.
    final currentName = GoRouterState.of(context).topRoute?.name;

    // -1 quando a rota não é uma aba: cai na Home, a mentira menos
    // surpreendente, já que a `NavigationBar` exige aba acesa. Ver ADR 0006.
    final index = NavBarOptions.all.indexWhere(
      (o) => o.routeName == currentName,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          context.goNamed(NavBarOptions.all[index].routeName);
        },

        selectedIndex: index == -1
            ? NavBarOptions.all.indexWhere(
                (e) => e.routeName == AppRouteNames.home,
              )
            : index,
        destinations: NavBarOptions.all
            .map(
              (e) => NavigationDestination(icon: Icon(e.icon), label: e.label),
            )
            .toList(),
      ),
      body: child,
    );
  }
}

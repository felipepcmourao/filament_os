import 'package:filament_os/core/router/app_route_names.dart';
import 'package:flutter/material.dart';

/// Um destino da barra de navegação: para onde vai, com que ícone e que nome.
typedef NavigationBarOption = ({String routeName, IconData icon, String label});

/// Os destinos da barra, **na ordem em que aparecem nela**. Única fonte da
/// barra: reordenar aqui reordena tudo, de forma coerente. Ver ADR 0006.
///
/// Mora em `core/presentation/`, e não em `core/router/`, porque guarda ícone
/// e texto de tela; conversa com o roteador só pelo `routeName`.
class NavBarOptions {
  static const List<NavigationBarOption> all = [
    (
      routeName: AppRouteNames.filaments,
      icon: Icons.circle,
      label: 'Filamentos',
    ),
    (routeName: AppRouteNames.home, icon: Icons.home, label: 'Início'),
    (routeName: AppRouteNames.prints, icon: Icons.print, label: 'Impressões'),
  ];
}

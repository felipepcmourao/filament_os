import 'package:filament_os/core/router/app_route_names.dart';
import 'package:flutter/material.dart';

/// Um destino da barra de navegação: para onde vai, com que ícone e que nome.
///
/// É um Record, e não três listas paralelas, pelo mesmo motivo que fez
/// `FilamentUsage` virar um no domínio: valores que precisam andar juntos
/// andam juntos. Antes, os nomes de rota viviam numa `List<String>` no
/// `AppRouteNames` e os ícones/rótulos noutra lista dentro do `ShellRouter`,
/// e as duas tinham que ficar na mesma ordem à mão — nada no compilador
/// verificava, e reordenar só uma fazia a barra navegar para a tela errada.
typedef NavigationBarOption = ({String routeName, IconData icon, String label});

/// Os destinos da barra, **na ordem em que aparecem nela**.
///
/// Esta lista é a única fonte da barra: o `ShellRouter` desenha as
/// `destinations` a partir dela, descobre a aba acesa procurando o
/// `routeName` da rota atual, e traduz o índice tocado de volta em nome pelo
/// mesmo caminho. Reordenar aqui reordena a barra inteira, de forma coerente.
///
/// Mora em `core/presentation/`, e não em `core/router/`, porque guarda ícone
/// e texto de tela — a pasta do roteador guarda configuração de rota. Só o
/// `routeName` é vocabulário de navegação, e é por ele que esta lista conversa
/// com o roteador, sem nunca tocar em `AppPaths`.
///
/// Guarda `IconData` e não `Icon`: o primeiro é dado, o segundo é widget.
/// O `Icon(...)` nasce no `build` do `ShellRouter`, que é onde decisões de
/// tamanho e cor pertencem.
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

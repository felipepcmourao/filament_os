import 'package:filament_os/core/router/app_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A moldura que fica em volta das três áreas do app.
///
/// Recebe a tela que casou com a URL (`child`) e a desenha dentro de um
/// `Scaffold` que segura a `NavigationBar`. Como o `ShellRoute` mantém esta
/// instância viva enquanto só o `child` troca, a barra é **a mesma** ao mudar
/// de aba — não morre e renasce, que é o que aconteceria se cada tela tivesse
/// a sua.
///
/// São dois `Scaffold` aninhados, de propósito: este segura o que persiste (a
/// barra), e o de cada tela segura o que é dela (a `AppBar`, o `body`).
///
/// É `StatelessWidget` porque não guarda nada. A aba acesa é **derivada** da
/// URL a cada build, não salva num campo — mesma ideia do `StockStatus`, que
/// se calcula a partir do peso em vez de viver no `Filament`. Guardar um
/// índice criaria uma segunda fonte de verdade, e ela desincronizaria na
/// primeira navegação que não viesse da barra: um toque no botão da `HomePage`
/// ou um deep link direto em `/prints` mudariam a tela sem passar pelo
/// `onDestinationSelected`, e a barra ficaria acesa na aba errada.
class ShellRouter extends StatelessWidget {
  final Widget child;

  const ShellRouter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // `topRoute` é a rota mais profunda que casou com a URL atual, e `.name` é
    // o nome declarado nela lá no `app_router.dart` — 'home', 'filaments' ou
    // 'prints'. Comparar nome com nome é o que dispensa `AppPaths` aqui: este
    // widget não precisa saber como as URLs se escrevem.
    final currentName = GoRouterState.of(context).topRoute?.name;

    // -1 quando a rota atual não é nenhuma das três abas. Hoje não acontece,
    // porque só essas três vivem dentro do shell — mas `NavigationBar` estoura
    // uma assertion com índice fora da faixa, e uma tela que quebra por causa
    // da própria decoração é pior que uma aba acesa errada. Cair no 0 é a
    // escolha conservadora, não a definitiva: quando entrar uma rota nova no
    // shell, decida o que a barra deve mostrar em vez de herdar este default.
    final index = AppRouteNames.navBarPages.indexOf(currentName ?? '');

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        // O índice tocado vira nome pela mesma lista que alimenta o
        // `selectedIndex` — ida e volta pelo mesmo mapeamento, então não tem
        // como as duas direções discordarem.
        onDestinationSelected: (index) =>
            context.goNamed(AppRouteNames.navBarPages[index]),
        selectedIndex: index == -1 ? 0 : index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.circle), label: 'Filamentos'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.toys), label: 'Impressões'),
        ],
      ),
      body: child,
    );
  }
}
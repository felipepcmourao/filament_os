import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/presentation/nav_bar_options.dart';
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
    // da própria decoração é pior que uma aba acesa errada.
    //
    // O fallback é a Home, para não contradizer o `initialLocation: '/'` do
    // roteador: se o app assume a Home como ponto de partida quando não há
    // URL, a barra assume a mesma coisa quando não reconhece a URL. Note que
    // as duas saídas são mentira — a `NavigationBar` não aceita "nenhuma aba
    // selecionada", o `selectedIndex` é um `int` obrigatório e dentro da
    // faixa. Escolhe-se a mentira menos surpreendente, não a verdade.
    //
    // O índice da Home é procurado, não escrito à mão, para não depender da
    // ordem de `NavBarOptions.all`: reordenar a lista não pode mudar em
    // silêncio para onde o fallback aponta.
    final index = NavBarOptions.all.indexWhere(
      (o) => o.routeName == currentName,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        // Ícone, rótulo, nome de rota e ordem saem todos de `NavBarOptions`,
        // e é isso que torna a barra consistente por construção: o índice que
        // chega aqui é posição na mesma lista que desenhou as `destinations`,
        // então não existe estado onde o ícone tocado e o destino discordem.
        //
        // Já foram duas listas paralelas — nomes de rota no `AppRouteNames` e
        // ícones/rótulos aqui — que precisavam ficar na mesma ordem à mão.
        // Verificado: naquele desenho, reordenar só uma delas deixava a suíte
        // vermelha; neste, reordenar a lista única mantém tudo verde, porque
        // não há segunda lista para discordar. Mesmo motivo que fez
        // `FilamentUsage` virar um Record no domínio.
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

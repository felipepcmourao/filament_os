import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:filament_os/core/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A tela de entrada do app, alcançada por `/`.
///
/// Mora em `features/dashboard/` porque é o lugar dela no fim: um painel com
/// estoque total, impressões recentes e lucro do mês. Hoje não tem nada disso
/// — é um título e botões avulsos (navegar pra filamentos, testar o 404,
/// trocar de tema), cada um andaime de uma sessão diferente.
///
/// Não conhece a `FilamentsPage`: manda o roteador ir pra `/filaments` e quem
/// resolve isso em widget é o `AppRouter`. Foi essa inversão que permitiu à
/// regra "nenhuma feature importa a presentation de outra" valer de fato —
/// antes esta tela dava `Navigator.push(FilamentsPage())` e, com isso, o
/// dashboard dependia da feature de filamentos em tempo de compilação.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(
                'FilamentOS',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.filaments),
                child: const Text('Filamentos'),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Andaime temporário: é o único jeito de chegar na `NotFoundPage`
              // sem digitar URL à mão, o que no emulador dá trabalho.
              //
              // É também a única navegação por string literal do app, e aqui
              // isso não fere a convenção — fere pelo motivo certo. Navegar por
              // nome (`AppRouteNames`) só alcança destinos que existem, e o que
              // se quer testar é justamente um caminho que NÃO existe. Uma
              // constante em `AppPaths` pra uma rota inválida seria uma
              // contradição: aquela classe descreve o espaço de URLs válido.
              //
              // Sai daqui quando o teste de navegação da Sessão 5 cobrir o 404
              // de verdade — teste automatizado não precisa de botão na tela.
              ElevatedButton(
                onPressed: () => context.go('dsada'),
                child: const Text('Teste Not Found'),
              ),

              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
                child: const Text('Tema Escuro'),
              ),
              ElevatedButton(
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
                child: const Text('Tema Claro'),
              ),
              ElevatedButton(
                onPressed: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
                child: const Text('Tema do Dispositivo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

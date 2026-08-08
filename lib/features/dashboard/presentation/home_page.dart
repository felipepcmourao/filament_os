import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => context.go(AppPaths.filaments),
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
            ],
          ),
        ),
      ),
    );
  }
}

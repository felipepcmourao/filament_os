import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela mostrada quando a URL não corresponde a rota nenhuma.
///
/// Não é "filamento não encontrado": `/filaments/id-inexistente` casa com a
/// rota `:id`, e quem trata a ausência é a `FilamentDetailsPage`.
///
/// Mostra a URL tentada para ajudar a depurar, mas como detalhe, abaixo da
/// explicação: quem lê quer primeiro saber o que houve.
///
/// O botão para a home evita um beco sem saída, porque esta tela costuma
/// chegar por URL direta, sem nada na pilha; por isso `go`, e não `push`.
class NotFoundPage extends StatelessWidget {
  final String uri;
  const NotFoundPage({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404 - Não encontrado')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ixi, não tá aqui! Clica aí embaixo pra ter acesso ao app.',
                style: Theme.of(context).textTheme.titleMedium!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Você tentou acessar: $uri',
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => context.goNamed(AppRouteNames.home),
                child: const Text('Acessar app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

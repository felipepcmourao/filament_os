import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela mostrada quando a URL não corresponde a rota nenhuma.
///
/// Mora em `core/`, e não numa feature, porque não pertence a nenhuma: um
/// caminho inválido não é assunto de filamentos nem de impressões. E fica em
/// `core/presentation/`, separada de `core/router/`, porque é um widget — a
/// pasta do roteador guarda configuração, não tela.
///
/// **Não confundir com "filamento não encontrado".** São dois erros em
/// camadas diferentes: `/filamentos` (em português) não casa com rota alguma
/// e cai aqui; já `/filaments/id-inexistente` casa perfeitamente com a rota
/// `:id` — ali o roteador acertou, e quem trata a ausência é a própria
/// `FilamentDetailsPage`, depois de consultar o repositório.
///
/// Exibe a URL tentada e o erro porque "não encontrado" sem dizer *o quê* não
/// ajuda ninguém a depurar — mas em `bodyMedium`, abaixo da explicação em
/// `titleMedium`: quem lê quer primeiro saber o que houve, o resto é detalhe.
///
/// O botão para a home não é enfeite. Esta tela costuma ser alcançada por URL
/// direta, sem tela anterior na pilha, então sem ele o usuário fica num beco
/// sem saída. Usa `go` porque não há para onde voltar — é substituição de
/// caminho, não empilhamento.
class NotFoundPage extends StatelessWidget {
  final String uri;
  final String error;
  const NotFoundPage({super.key, required this.uri, required this.error});

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
                'Você tentou acessar: $uri',
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Erro: $error',
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Ixi, não tá aqui! Clica aí embaixo pra ter acesso ao app.',
                style: Theme.of(context).textTheme.titleMedium!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () => context.go(AppPaths.home),
                child: const Text('Acessar app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

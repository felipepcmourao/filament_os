import 'package:filament_os/features/filaments/presentation/filament_by_id_provider.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_label.dart';
import 'package:filament_os/shared/presentation/weight_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detalhe de um filamento, alcançada por `/filaments/<id>`.
///
/// Recebe o `id` e busca o filamento sozinha — não recebe um `Filament`
/// pronto da tela anterior. É o que torna deep link viável: uma URL carrega
/// texto, não objeto, então uma tela que só funciona quando a anterior lhe
/// entrega a entidade quebra ao ser aberta de fora do app. O custo é ter que
/// lidar com carregamento e com id inexistente, que é o que o `.when` abaixo
/// faz, tratando `null` (id não encontrado na lista) como um caso de `data`,
/// não de `error`.
///
/// `ConsumerWidget` que observa `filamentByIdProvider(id)` — um provider
/// derivado de `filamentsListProvider`, não uma busca independente. Por
/// isso um filamento adicionado na `FilamentsPage` aparece aqui: as duas
/// telas leem a mesma lista, vinda da mesma instância de
/// `FilamentsRepository`, em vez de cada uma instanciar a própria (o
/// problema que existia antes da Sessão 6).
class FilamentDetailsPage extends ConsumerWidget {
  final String id;

  const FilamentDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filament = ref.watch(filamentByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(id)),
      body: SafeArea(
        child: filament.when(
          data: (data) => data == null
              ? Center(
                  child: Text(
                    'Filamento indisponível',
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Text(data.name),
                    const Divider(),
                    Text(data.color.label),
                    const Divider(),
                    Text(data.weightInGrams.label),
                  ],
                ),
          error: (err, stack) => Center(
            child: Text(
              'Erro: $err',
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

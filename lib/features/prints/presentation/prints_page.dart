import 'package:filament_os/features/filaments/presentation/filaments_list_notifier.dart';
import 'package:filament_os/features/prints/di/register_print_provider.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/presentation/prints_list_notifier.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lista de impressões, alcançada por `/prints`.
///
/// O botão "Registrar Impressão" chama `RegisterPrint` (via
/// `registerPrintProvider`), que escreve direto nos repositórios de `Print` e
/// `Filament` — não passa pelos notifiers. Por isso, depois do `await`, o
/// `onPressed` invalida `printsListProvider` **e** `filamentsListProvider` na
/// mão: sem isso, os dois ficariam com o estado antigo em cache, mesmo com o
/// dado já persistido. É o que faz a impressão nova aparecer aqui e o estoque
/// debitado aparecer na `FilamentsPage`, sem reiniciar o app nem recarregar
/// nada manualmente.
///
/// `printId`/`filamentUsage` fixos no botão são andaime deliberado (mesmo
/// espírito de `addedFilament1/2/3` na `FilamentsPage`): clicar duas vezes
/// gera dois `Print` com o mesmo id, porque nem `Print` nem
/// `PrintsRepositoryFakeImpl.add()` barram isso. Sai quando existir um
/// formulário de verdade.
class PrintsPage extends ConsumerWidget {
  const PrintsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filaments = ref.watch(filamentsListProvider);
    final prints = ref.watch(printsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Impressões')),
      body: SafeArea(
        child: Column(
          children: [
            prints.when(
              data: (data) => data.isEmpty
                  ? const Center(child: Text('Sem impressões registradas'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final print = data[index];
                          return ListTile(title: Text(print.name));
                        },
                      ),
                    ),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            filaments.when(
              data: (data) => data.isEmpty
                  ? const Center(
                      child: Text('Adicione um filamento para imprimir'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(registerPrintProvider)
                            .call(
                              printId: '0000001',
                              ownerId: '000001',
                              status: PrintStatus.printing,
                              name: 'Chaveiro Flamengo',
                              filamentUsage: [
                                (
                                  filamentId: '00003',
                                  usedGrams: Weight(weightInMiligrams: 30000),
                                ),
                              ],
                              finalWeight: Weight(weightInMiligrams: 30000),
                              printTime: 1.25,
                              dateTime: DateTime.now(),
                            );

                        ref.invalidate(printsListProvider);
                        ref.invalidate(filamentsListProvider);
                      },
                      child: const Text('Registrar Impressão'),
                    ),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

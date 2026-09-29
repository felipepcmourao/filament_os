import 'package:filament_os/features/filaments/presentation/filaments_list_notifier.dart';
import 'package:filament_os/features/prints/di/register_print_provider.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/presentation/prints_list_notifier.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:filament_os/shared/presentation/error_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lista de impressões, alcançada por `/prints`.
///
/// O botão invalida os dois providers na mão porque o `RegisterPrint` escreve
/// direto nos repositórios, sem passar pelos notifiers.
///
/// `printId` e `filamentUsage` fixos são andaime até existir um formulário:
/// clicar duas vezes gera dois `Print` com o mesmo id.
class PrintsPage extends StatelessWidget {
  const PrintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressões'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final prints = ref.watch(printsListProvider);
                  return prints.when(
                    data: (data) => data.isEmpty
                        ? const Center(
                            child: Text('Sem impressões registradas'),
                          )
                        : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final print = data[index];
                              return ListTile(title: Text(print.name));
                            },
                          ),
                    error: (err, stack) => ErrorMessageView(error: err),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final filaments = ref.watch(filamentsListProvider);
                return filaments.when(
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
                                      usedGrams: Weight(
                                        weightInMilligrams: 30000,
                                      ),
                                    ),
                                  ],
                                  finalWeight: Weight(
                                    weightInMilligrams: 30000,
                                  ),
                                  printTime: 1.25,
                                  dateTime: DateTime.now(),
                                );

                            ref.invalidate(printsListProvider);
                            ref.invalidate(filamentsListProvider);
                          },
                          child: const Text('Registrar Impressão'),
                        ),
                  error: (err, stack) => ErrorMessageView(error: err),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/core/theme/app_radius.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_label.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_material.dart';
import 'package:filament_os/features/filaments/presentation/filament_type_label.dart';
import 'package:filament_os/features/filaments/presentation/filaments_list_notifier.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:filament_os/shared/domain/stock_status.dart';
import 'package:filament_os/shared/presentation/error_message_view.dart';
import 'package:filament_os/shared/presentation/stock_status_label.dart';
import 'package:filament_os/shared/presentation/stock_status_material.dart';
import 'package:filament_os/shared/presentation/weight_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lista o estoque de filamentos, alcançada por `/filaments`.
///
/// Só a lista fica num `Consumer`, para `Scaffold` e `AppBar` não
/// reconstruírem a cada mudança. Ver ADR 0007.
///
/// Cada item mostra a cor também escrita e o estoque num badge: nenhuma
/// informação depende só de cor, para quem não a distingue.
class FilamentsPage extends StatelessWidget {
  const FilamentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filaments Page'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final filaments = ref.watch(filamentsListProvider);
            return filaments.when(
              data: (data) => data.isEmpty
                  ? Center(
                      child: TextButton(
                        onPressed: () async {
                          final filamentList = ref.read(
                            filamentsListProvider.notifier,
                          );
                          await filamentList.addFilament(addedFilament1);
                          await filamentList.addFilament(addedFilament2);
                          await filamentList.addFilament(addedFilament3);
                        },
                        child: const Text('Adicionar Filamento'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, int index) {
                        final filament = data[index];
                        final status = StockStatus.fromWeight(filament.weight);
                        final color = Theme.of(context).extension<AppColors>();
                        return ListTile(
                          onTap: () => context.goNamed(
                            AppRouteNames.filamentDetails,
                            pathParameters: {AppPaths.idParam: filament.id},
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(filament.name),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  color: status.toMaterial(color!).container,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    child: Text(
                                      status.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .apply(
                                            color: status
                                                .toMaterial(color)
                                                .content,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(filament.type.label),
                              const VerticalDivider(),
                              Text(filament.weight.label),
                              const VerticalDivider(),
                              Text(filament.color.label),
                            ],
                          ),
                          // Borda no `outline` porque a cor do filamento não
                          // muda com o tema: sem ela, o amarelo some no claro.
                          leading: Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              color: filament.color.toMaterial(),
                            ),
                            height: AppSpacing.sm,
                            width: AppSpacing.sm,
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              final filamentList = ref.read(
                                filamentsListProvider.notifier,
                              );
                              await filamentList.removeFilament(filament.id);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    ),
              error: (err, stack) => ErrorMessageView(error: err),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}

// Andaime até existir persistência: o botão "Adicionar Filamento" os usa.
//
// Os pesos 0g, 80g e 450g dão um filamento de cada `StockStatus`; mudá-los
// apaga essa cobertura em silêncio.
final addedFilament1 = Filament(
  id: '00001',
  name: 'BambuLab PLA Silk',
  ownerId: '92',
  type: FilamentType.plaSilk,
  diameterInMms: 1.75,
  color: FilamentColor.yellow,
  weight: Weight.fromGrams(weightInGrams: 0),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

final addedFilament2 = Filament(
  id: '00002',
  name: 'BambuLab PLA Silk',
  ownerId: '92',
  type: FilamentType.plaSilk,
  diameterInMms: 1.75,
  color: FilamentColor.pink,
  weight: Weight.fromGrams(weightInGrams: 80),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

final addedFilament3 = Filament(
  id: '00003',
  name: 'BambuLab PLA Silk',
  ownerId: '92',
  type: FilamentType.plaSilk,
  diameterInMms: 1.75,
  color: FilamentColor.blue,
  weight: Weight.fromGrams(weightInGrams: 450),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

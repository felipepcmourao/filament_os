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
/// `StatelessWidget`, não `ConsumerWidget`: quem guarda o estado é o
/// `FilamentsListNotifier`, via `filamentsListProvider`, e só a parte da
/// árvore que lê esse provider (`ref.watch`) precisa reconstruir a cada
/// mudança. Um `Consumer` isolado em volta da lista cumpre isso — `Scaffold`
/// e `AppBar` ficam fora do rebuild, que um `ConsumerWidget` na classe
/// inteira não evitaria. Dentro do `Consumer`, trata os três estados
/// (`loading`, `error`, `data`) do `AsyncValue<List<Filament>>` com `.when`.
///
/// Cada `ListTile` mostra a mesma informação três vezes em linguagens
/// diferentes, e isso é de propósito: o swatch colorido, o nome da cor escrito
/// e o badge de estoque. Cor sozinha não informa quem não a distingue, e por
/// isso nenhuma informação depende só dela aqui.
///
/// Adicionar e remover filamento chamam métodos do notifier
/// (`addFilament`/`removeFilament`), nunca o repositório direto — a tela não
/// conhece `FilamentsRepository`, só o provider que já expõe a lista pronta.
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
                          // Navega por NOME, não por path: esta tela não sabe
                          // que a URL do detalhe é `/filaments/<id>`, só que
                          // existe um destino chamado `filamentDetails`.
                          //
                          // E passa o `id`, não o `filament`. A tela de destino
                          // busca sozinha — é o que faz ela funcionar também
                          // quando aberta por link, sem esta tela no caminho.
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
                          // O nome da cor aparece aqui como texto, e não só
                          // como o quadradinho colorido do `leading`: quem não
                          // distingue cores não recebe informação nenhuma de um
                          // swatch sozinho. Texto ao lado resolve pra todo
                          // mundo, sem depender de leitor de tela.
                          subtitle: Row(
                            children: [
                              Text(filament.type.label),
                              const VerticalDivider(),
                              Text(filament.weight.label),
                              const VerticalDivider(),
                              Text(filament.color.label),
                            ],
                          ),
                          // Swatch puramente decorativo — a informação que ele
                          // carrega já está escrita no `subtitle`.
                          //
                          // A borda vem de `colorScheme.outline` porque a cor
                          // do filamento é dado do produto e não se adapta ao
                          // tema (ver `FilamentColorMaterial`): sem contorno,
                          // um amarelo some no fundo claro e um cinza escuro
                          // some no escuro. O contraste mora na borda, que o
                          // tema controla, não na cor, que ele não deve tocar.
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

// Dados de demonstração, presos no arquivo enquanto não existe persistência.
// O botão "Adicionar Filamento" despeja os três de uma vez só pra tela sair do
// estado vazio — não é feature, é andaime.
//
// Os pesos não são arbitrários: 0g, 80g e 450g dão um filamento de cada
// `StockStatus` (`exhausted`, `low` e `healthy`, com o limiar de 100g que o
// `StockStatus.fromWeight` aplica). É o que permite ver os três badges lado a
// lado sem mexer em nada. Mudar esses números apaga essa cobertura em silêncio.
//
// Saem daqui quando os dados vierem do Hive/Firestore. Enquanto isso, ficam
// fora da classe de propósito: são fixture, não estado da tela.
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

import 'package:filament_os/core/router/app_paths.dart';
import 'package:filament_os/core/router/app_route_names.dart';
import 'package:filament_os/core/theme/app_colors.dart';
import 'package:filament_os/core/theme/app_radius.dart';
import 'package:filament_os/core/theme/app_spacing.dart';
import 'package:filament_os/features/filaments/data/filaments_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_label.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_material.dart';
import 'package:filament_os/features/filaments/presentation/filament_type_label.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:filament_os/shared/domain/stock_status.dart';
import 'package:filament_os/shared/presentation/stock_status_label.dart';
import 'package:filament_os/shared/presentation/stock_status_material.dart';
import 'package:filament_os/shared/presentation/weight_label.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista o estoque de filamentos, alcançada por `/filaments`.
///
/// É `StatefulWidget` porque precisa guardar o Future entre rebuilds (ver o
/// campo `_futureFilamentList`) e trocá-lo por um novo quando a lista muda.
///
/// Cada `ListTile` mostra a mesma informação três vezes em linguagens
/// diferentes, e isso é de propósito: o swatch colorido, o nome da cor escrito
/// e o badge de estoque. Cor sozinha não informa quem não a distingue, e por
/// isso nenhuma informação depende só dela aqui.
///
/// Instancia o próprio repositório, como todas as telas hoje — é a dívida que
/// o `flutter_riverpod` fecha na Sessão 6, e a razão pela qual a
/// `FilamentDetailsPage` nunca acha o filamento que esta tela adicionou (ver
/// `FilamentDetailsPage`, que documenta o caso por inteiro).
class FilamentsPage extends StatefulWidget {
  const FilamentsPage({super.key});

  @override
  State<FilamentsPage> createState() => _FilamentsPageState();
}

class _FilamentsPageState extends State<FilamentsPage> {
  final filamentRepository = FilamentsRepositoryFakeImpl();

  // `filamentRepository.list()` devolve um Future<List<Filament>>, não a
  // lista em si — por isso essa variável guarda o Future, e não uma List.
  late Future<List<Filament>> _futureFilamentList;

  @override
  void initState() {
    // Dispara a consulta ao repositório assim que a página é criada.
    // Nesse ponto o Future ainda não resolveu — quem espera ele resolver
    // é o FutureBuilder lá embaixo, no build().
    _futureFilamentList = filamentRepository.list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filaments Page'),
        scrolledUnderElevation: 0,
      ),
      // FutureBuilder reconstrói a tela sozinho quando o Future resolve:
      // enquanto está "esperando", mostra um estado; quando termina,
      // `snapshot.data` já é a List<Filament> de verdade.
      body: SafeArea(
        child: FutureBuilder(
          future: _futureFilamentList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError == true) {
              return Center(
                child: Text(
                  'Erro: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
            final filamentList = snapshot.data ?? const [];
            return filamentList.isEmpty
                ? Center(
                    child: TextButton(
                      onPressed: () async {
                        await filamentRepository.add(addedFilament1);
                        await filamentRepository.add(addedFilament2);
                        await filamentRepository.add(addedFilament3);
                        // Um Future só resolve uma vez. Depois de adicionar
                        // um filamento no repositório, o Future antigo não
                        // "atualiza sozinho" — por isso criamos um Future
                        // NOVO aqui, e o setState faz o FutureBuilder
                        // reconstruir a tela com ele.
                        if (!mounted) return;
                        setState(() {
                          _futureFilamentList = filamentRepository.list();
                        });
                      },
                      child: const Text('Adicionar Filamento'),
                    ),
                  )
                : ListView.builder(
                    itemCount: filamentList.length,
                    itemBuilder: (context, int index) {
                      final filament = filamentList[index];
                      final status = StockStatus.fromWeight(
                        filament.weightInGrams,
                      );
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
                            Text(filament.weightInGrams.label),
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
                            await filamentRepository.remove(filament.id);
                            // Mesma lógica do add: novo Future, novo setState,
                            // pra lista recarregar depois da remoção.
                            if (!mounted) return;
                            setState(() {
                              _futureFilamentList = filamentRepository.list();
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    },
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
  weightInGrams: Weight.fromGrams(weightInGrams: 0),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

final addedFilament2 = Filament(
  id: '00002',
  name: 'BambuLab PLA Silk',
  ownerId: '92',
  type: FilamentType.plaSilk,
  diameterInMms: 1.75,
  color: FilamentColor.pink,
  weightInGrams: Weight.fromGrams(weightInGrams: 80),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

final addedFilament3 = Filament(
  id: '00003',
  name: 'BambuLab PLA Silk',
  ownerId: '92',
  type: FilamentType.plaSilk,
  diameterInMms: 1.75,
  color: FilamentColor.blue,
  weightInGrams: Weight.fromGrams(weightInGrams: 450),
  totalCost: Money(amountInCents: 1000, currency: 'EUR'),
);

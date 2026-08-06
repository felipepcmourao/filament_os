import 'package:filament_os/features/filaments/data/filaments_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_label.dart';
import 'package:flutter/material.dart';

/// Detalhe de um filamento, alcançada por `/filaments/<id>`.
///
/// Recebe o `id` e busca o filamento sozinha — não recebe um `Filament`
/// pronto da tela anterior. É o que torna deep link viável: uma URL carrega
/// texto, não objeto, então uma tela que só funciona quando a anterior lhe
/// entrega a entidade quebra ao ser aberta de fora do app. O custo é ter que
/// lidar com carregamento e com id inexistente, que é o que o `FutureBuilder`
/// abaixo faz.
///
/// ATENÇÃO — hoje esta tela nunca acha nada, e o motivo NÃO está aqui.
/// Cada tela instancia o próprio `FilamentsRepositoryFakeImpl`, e o fake
/// guarda os dados numa lista de instância. A `FilamentsPage` popula a lista
/// *dela*; esta página nasce com uma lista vazia e sempre cai no ramo de
/// "não encontrado". A tela está correta — falta injeção de dependência, ou
/// seja, alguém de fora decidindo qual instância do repositório cada tela
/// usa, em vez de cada uma criar a sua.
///
/// Uma tentativa de remendo (tornar a lista do fake `static`) foi revertida:
/// estado global compartilhado quebrou o isolamento entre testes, e um deles
/// passou a herdar os dados do anterior. O conserto de verdade é o
/// `flutter_riverpod`, na Sessão 6.
class FilamentDetailsPage extends StatefulWidget {
  final String id;

  const FilamentDetailsPage({super.key, required this.id});

  @override
  State<FilamentDetailsPage> createState() => _FilamentDetailsPageState();
}

class _FilamentDetailsPageState extends State<FilamentDetailsPage> {
  final filamentRepository = FilamentsRepositoryFakeImpl();

  // Mesma estrutura da `FilamentsPage`: o Future é guardado em campo e
  // disparado uma vez no `initState`, não dentro do `build`. Criar o Future
  // no build faria uma consulta nova a cada reconstrução da tela.
  late Future<List<Filament>> _futureFilamentList;

  @override
  void initState() {
    _futureFilamentList = filamentRepository.list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id)),
      body: SafeArea(
        child: FutureBuilder(
          future: _futureFilamentList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
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
            final index = filamentList.indexWhere((e) => e.id == widget.id);

            // Id não encontrado não é erro de programação: acontece com link
            // antigo, filamento apagado, ou URL digitada à mão. Por isso vira
            // mensagem na tela e não exceção. `indexWhere` já devolve `-1`
            // quando a lista está vazia, então este ramo cobre os dois casos
            // sem precisar de um `isEmpty` separado.
            if (index == -1) {
              return Center(
                child: Text(
                  'Filamento indisponível',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            final filament = filamentList[index];

            return Column(
              children: [
                Text(filament.name),
                const Divider(),
                Text(filament.color.label),
                const Divider(),
                Text(filament.weightInGrams.toString()),
              ],
            );
          },
        ),
      ),
    );
  }
}

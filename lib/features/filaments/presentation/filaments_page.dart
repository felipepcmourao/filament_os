import 'package:filament_os/features/filaments/data/filament_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:flutter/material.dart';

class FilamentsPage extends StatefulWidget {
  const FilamentsPage({super.key});

  @override
  State<FilamentsPage> createState() => _FilamentsPageState();
}

class _FilamentsPageState extends State<FilamentsPage> {
  final filamentRepository = FilamentRepositoryFakeImpl();

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Filaments Page')),
        // FutureBuilder reconstrói a tela sozinho quando o Future resolve:
        // enquanto está "esperando", mostra um estado; quando termina,
        // `snapshot.data` já é a List<Filament> de verdade.
        body: FutureBuilder(
          future: _futureFilamentList,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            final filamentList = snapshot.data ?? const [];
            return filamentList.isEmpty
                ? Center(
                    child: TextButton(
                      onPressed: () {
                        filamentRepository.add(
                          Filament(
                            id: '00001',
                            name: 'BambuLab PLA Silk',
                            ownerId: '92',
                            type: 'PLA Silk',
                            diameterInMms: 17.5,
                            color: 'red',
                            quantityInGrams: 1000,
                            totalCost: Money(amountInCents: 1000, currency: 'EUR'),
                          ),
                        );
                        // Um Future só resolve uma vez. Depois de adicionar
                        // um filamento no repositório, o Future antigo não
                        // "atualiza sozinho" — por isso criamos um Future
                        // NOVO aqui, e o setState faz o FutureBuilder
                        // reconstruir a tela com ele.
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
                      return ListTile(
                        title: Text(filament.name),
                        subtitle: Text(filament.type),
                        trailing: IconButton(
                          onPressed: () async {
                            await filamentRepository.remove(filament.id);
                            // Mesma lógica do add: novo Future, novo setState,
                            // pra lista recarregar depois da remoção.
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

import 'package:filament_os/features/filaments/data/filament_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:flutter/material.dart';

class FilamentsPage extends StatefulWidget {
  const FilamentsPage({super.key});

  @override
  State<FilamentsPage> createState() => _FilamentsPageState();
}

class _FilamentsPageState extends State<FilamentsPage> {
  final filamentRepository = FilamentRepositoryFakeImpl();

  @override
  Widget build(BuildContext context) {
    final filamentList = filamentRepository.list();
    return Scaffold(
      appBar: AppBar(title: const Text('Filaments Page')),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: filamentList.isEmpty
                  ? Center(
                      child: TextButton(
                        onPressed: () {
                          filamentRepository.add(
                            const Filament(
                              id: '00001',
                              name: 'BambuLab PLA Silk',
                              material: 'PLA',
                              quantityInGrams: 1000,
                            ),
                          );
                          setState(() {});
                        },
                        child: const Text('Add Filamento'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filamentList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final filament = filamentList[index];
                        return ListTile(
                          title: Text(filament.name),
                          subtitle: Text(filament.material),
                          trailing: IconButton(
                            onPressed: (){
                              filamentRepository.remove(filament.id);
                              setState(() {
                                
                              });
                            }, icon: const Icon(Icons.delete)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

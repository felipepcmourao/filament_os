import 'package:filament_os/features/filaments/domain/filament_repository_fake_impl.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Filaments Page')),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: ListView.builder(
            itemCount: filamentRepository.filamentList.length,
            itemBuilder: (BuildContext bc, int index) {
              final filament = filamentRepository.filamentList[index];
              return filamentRepository.filamentList.isEmpty || filamentRepository.filamentList == null
              ? Container(color: Colors.red, height: 20, width: 20,)
              : ListTile(
                title: Text(filament.name),
                subtitle: Text(filament.material),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';

class FilamentRepositoryFakeImpl implements FilamentRepository {
  List<Filament> filamentList = [
    const Filament(id: 'a', name: 'a', material: 'a', quantityInGrams: 123.45),
    const Filament(id: 'b', name: 'b', material: 'b', quantityInGrams: 678.90),
  ];
  @override
  void list() {
    print(filamentList.join(' - '));
  }

  @override
  void add(Filament filament) {
    filamentList.add(filament);

    print('New filament ${filament.name} added');
  }

  @override
  void remove(String id) {
    filamentList.removeWhere((e) => e.id == 'id');
    print('Filament removed');
  }
}

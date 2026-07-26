import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';

class FilamentRepositoryFakeImpl implements FilamentRepository {
  final List<Filament> _filamentList = [];

  @override
  List<Filament> list() {
    if (_filamentList.isEmpty) {
      return [];
    }
    return _filamentList;
  }

  @override
  String add(Filament filament) {
    _filamentList.add(filament);
    return 'Filamento adicionado';
  }

  @override
  String remove(String id) {
    _filamentList.removeWhere((e) => e.id == id);
    return 'Filamento removido';
  }
}

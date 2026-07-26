import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';

class FilamentRepositoryFakeImpl implements FilamentRepository {
  List<Filament> _filamentList = [];

  get filamentList => _filamentList;

  set filamentList (List<Filament> filamentList){
    _filamentList = filamentList;
  }

  @override
  String list() {
    if (_filamentList.isEmpty) {
      return 'Sem filamentos.';
    }
    return _filamentList.join(' \n\n ');
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

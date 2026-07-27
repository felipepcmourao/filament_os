import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';

class FilamentRepositoryFakeImpl implements FilamentRepository {
  final List<Filament> _filamentList = [];

  @override
  Future<List<Filament>> list() async {
    return List.unmodifiable(_filamentList);
  }

  @override
  Future<void> add(Filament filament) async {
    final currentLenght = _filamentList.length;
    _filamentList.add(filament);
    if (_filamentList.length <= currentLenght) throw Exception('Erro ao adicionar filamento');
  }

  @override
  Future<void> remove(String id) async {
    final currentLenght = _filamentList.length;
    _filamentList.removeWhere((e) => e.id == id);
    if (_filamentList.length >= currentLenght) throw Exception('Erro ao remover filamento');
  }
}

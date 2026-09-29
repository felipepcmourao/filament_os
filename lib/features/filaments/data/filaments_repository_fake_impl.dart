import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filaments_repository.dart';
import 'package:filament_os/shared/domain/app_exception.dart';

/// Guarda tudo numa lista em memória, que some quando o app fecha.
/// Ver ADR 0004.
class FilamentsRepositoryFakeImpl implements FilamentsRepository {
  final List<Filament> _filamentList = [];

  @override
  Future<List<Filament>> list() async {
    return List.unmodifiable(_filamentList);
  }

  @override
  Future<void> add(Filament filament) async {
    _filamentList.add(filament);
  }

  @override
  Future<void> update(Filament filament) async {
    final index = _filamentList.indexWhere((e) => e.id == filament.id);
    if (index == -1) throw FilamentNotUpdatedException(id: filament.id);
    _filamentList[index] = filament;
  }

  // `removeWhere` não avisa se não removeu nada; daí a comparação de tamanho.
  @override
  Future<void> remove(String id) async {
    final currentLength = _filamentList.length;
    _filamentList.removeWhere((e) => e.id == id);
    if (_filamentList.length >= currentLength) {
      throw FilamentNotRemovedException(id: id);
    }
  }
}

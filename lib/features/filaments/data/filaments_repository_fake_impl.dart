import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_not_removed_exception.dart';
import 'package:filament_os/features/filaments/domain/filament_not_updated_exception.dart';
import 'package:filament_os/features/filaments/domain/filaments_repository.dart';

/// Implementação "fake" do `FilamentsRepository`: guarda tudo numa lista em
/// memória, só pra desenvolver/testar sem precisar de um banco de dados de
/// verdade ainda. Os dados somem quando o app fecha.
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

  // Encontra o item pelo `id` e substitui pela versão nova. `indexWhere`
  // devolve `-1` quando não encontra nada — é esse cenário que a exceção
  // cobre (ex: tentar atualizar um Filament que já foi removido).
  @override
  Future<void> update(Filament filament) async {
    final index = _filamentList.indexWhere((e) => e.id == filament.id);
    if (index == -1) throw FilamentNotUpdatedException(id: filament.id);
    _filamentList[index] = filament;
  }

  // `removeWhere` não avisa se não removeu nada — por isso a checagem de
  // tamanho antes/depois, pra detectar "pediram pra remover um id que não
  // existe" e não falhar silenciosamente.
  @override
  Future<void> remove(String id) async {
    final currentLenght = _filamentList.length;
    _filamentList.removeWhere((e) => e.id == id);
    if (_filamentList.length >= currentLenght) {
      throw FilamentNotRemovedException(id: id);
    }
  }
}

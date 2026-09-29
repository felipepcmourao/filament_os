import 'package:filament_os/features/prints/domain/print.dart';
import 'package:filament_os/features/prints/domain/prints_repository.dart';
import 'package:filament_os/shared/domain/app_exception.dart';

/// Guarda tudo numa lista em memória, que some quando o app fecha.
/// Ver ADR 0004.
class PrintsRepositoryFakeImpl implements PrintsRepository {
  final List<Print> _printsList = [];

  // `unmodifiable` para ninguém alterar o estado interno por fora dos métodos.
  @override
  Future<List<Print>> list() async {
    return List.unmodifiable(_printsList);
  }

  @override
  Future<void> add(Print printedPiece) async {
    _printsList.add(printedPiece);
  }

  @override
  Future<void> update(Print printedPiece) async {
    final index = _printsList.indexWhere((e) => e.id == printedPiece.id);
    if (index == -1) throw PrintNotUpdatedException(printId: printedPiece.id);
    _printsList[index] = printedPiece;
  }

  // `removeWhere` não avisa se não removeu nada; daí a comparação de tamanho.
  @override
  Future<void> remove(String printId) async {
    final currentLength = _printsList.length;
    _printsList.removeWhere((e) => e.id == printId);
    if (_printsList.length >= currentLength) {
      throw PrintNotRemovedException(printId: printId);
    }
  }
}

import 'package:filament_os/features/prints/domain/print.dart';
import 'package:filament_os/features/prints/domain/prints_repository.dart';
import 'package:filament_os/shared/domain/app_exception.dart';

/// Implementação "fake" do `PrintsRepository`: guarda tudo numa lista em
/// memória, pelos mesmos motivos do `FilamentsRepositoryFakeImpl` e sob a
/// mesma ADR 0004 — dá pra construir e testar o fluxo de registro de
/// impressão sem depender de Hive, Firestore, rede ou autenticação. Os dados
/// somem quando o app fecha.
///
/// Replica os casos de erro que um banco real teria (`update`/`remove` de um
/// id inexistente) em vez de falhar em silêncio, pra que o código que a usa
/// já seja escrito contra o comportamento definitivo.
///
/// `add` não lança nada de propósito: inserir numa lista não tem caso de
/// "não encontrado" pra reportar. Mesma decisão do repositório de filamentos.
class PrintsRepositoryFakeImpl implements PrintsRepository {
  final List<Print> _printsList = [];

  // `List.unmodifiable` impede que quem recebe a lista altere o estado
  // interno do repositório por fora dos métodos dele.
  @override
  Future<List<Print>> list() async {
    return List.unmodifiable(_printsList);
  }

  @override
  Future<void> add(Print printedPiece) async {
    _printsList.add(printedPiece);
  }

  // Encontra pelo `id` e substitui pela versão nova. `indexWhere` devolve
  // `-1` quando não acha nada — é esse cenário que a exceção cobre.
  @override
  Future<void> update(Print printedPiece) async {
    final index = _printsList.indexWhere((e) => e.id == printedPiece.id);
    if (index == -1) throw PrintNotUpdatedException(printId: printedPiece.id);
    _printsList[index] = printedPiece;
  }

  // `removeWhere` não avisa se não removeu nada — daí a comparação de
  // tamanho antes/depois, pra detectar o id inexistente.
  @override
  Future<void> remove(String printId) async {
    final currentLength = _printsList.length;
    _printsList.removeWhere((e) => e.id == printId);
    if (_printsList.length >= currentLength) {
      throw PrintNotRemovedException(printId: printId);
    }
  }
}

import 'package:filament_os/features/prints/domain/print.dart';

/// Abstração da fonte de dados de `Print` — mesma ideia do
/// `FilamentsRepository`: nem `domain` nem quem usa esse contrato sabem se
/// por trás existe uma lista em memória, um banco local ou uma API.
///
/// Todo método é `Future` pelo mesmo motivo do `FilamentsRepository`: toda
/// fonte de dados real é assíncrona (banco, rede).
abstract class PrintsRepository {
  Future<List<Print>> list();
  Future<void> add(Print printedPiece);

  /// Substitui um `Print` já existente (mesmo `id`) pela versão nova —
  /// necessário sempre que o estado de uma impressão salva muda (ex:
  /// `status` de `printing` pra `successful`/`fail`).
  Future<void> update(Print printedPiece);
  Future<void> remove(String id);
}

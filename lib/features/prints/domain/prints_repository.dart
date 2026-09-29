import 'package:filament_os/features/prints/domain/print.dart';

/// Fonte de dados de `Print`, sem dizer qual. Ver ADR 0002.
abstract class PrintsRepository {
  Future<List<Print>> list();
  Future<void> add(Print printedPiece);

  /// Substitui o `Print` de mesmo `id`, como quando o `status` muda.
  Future<void> update(Print printedPiece);
  Future<void> remove(String id);
}

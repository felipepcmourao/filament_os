import 'package:filament_os/features/prints/domain/print.dart';

abstract class PrintsRepository {
  Future<List<Print>> list();
  Future<void> add(Print printedPiece);
  Future<void> update(Print printedPiece);
  Future<void> remove(String id);
}

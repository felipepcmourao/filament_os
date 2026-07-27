import 'package:filament_os/features/filaments/domain/filament.dart';

abstract class FilamentRepository {
  Future<List<Filament>> list();
  Future<void> add(Filament filament);
  Future<void> remove(String id);
}

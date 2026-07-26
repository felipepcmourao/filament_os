import 'package:filament_os/features/filaments/domain/filament.dart';

abstract class FilamentRepository {
  void list();
  void add(Filament filament);
  void remove(String id);
}

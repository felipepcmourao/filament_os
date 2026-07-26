import 'package:filament_os/features/filaments/domain/filament.dart';

abstract class FilamentRepository {
  List<Filament> list();
  String add(Filament filament);
  String remove(String id);
}

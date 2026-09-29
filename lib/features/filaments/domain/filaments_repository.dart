import 'package:filament_os/features/filaments/domain/filament.dart';

/// Fonte de dados de `Filament`, sem dizer qual. Ver ADR 0002.
///
/// Tudo é `Future` desde já, mesmo na fake, para que trocar pela fonte real
/// não mude quem consome o contrato.
abstract class FilamentsRepository {
  Future<List<Filament>> list();
  Future<void> add(Filament filament);

  /// Substitui o `Filament` de mesmo `id`, já que entity muda por instância
  /// nova, nunca por mutação.
  Future<void> update(Filament filament);
  Future<void> remove(String id);
}

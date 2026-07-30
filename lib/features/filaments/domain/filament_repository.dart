import 'package:filament_os/features/filaments/domain/filament.dart';

/// Abstração da fonte de dados de `Filament` — nem `domain` nem quem usa
/// esse contrato (ex: `RegisterPrint`) sabem se por trás existe uma lista
/// em memória, um banco local ou uma API. Isso é o que a ADR 0002 chama de
/// "desacoplamento entre regras de negócio e fontes de dados": trocar a
/// implementação (`FilamentRepositoryFakeImpl` por uma futura real) não
/// deveria exigir mudar nenhum use case ou entity.
///
/// Todo método é `Future` porque toda fonte de dados real é assíncrona
/// (banco, rede) — mesmo a fake respeitando essa assinatura desde já evita
/// ter que mudar quem consome o contrato quando a implementação mudar.
abstract class FilamentRepository {
  Future<List<Filament>> list();
  Future<void> add(Filament filament);

  /// Substitui um `Filament` já existente (mesmo `id`) pela versão nova —
  /// necessário sempre que uma entity já salva muda de estado (ex:
  /// `Filament.consumeGrams`, que devolve uma instância nova em vez de
  /// mutar a existente).
  Future<void> update(Filament filament);
  Future<void> remove(String id);
}

import 'package:equatable/equatable.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Estoque de um filamento comprado.
///
/// Pertence a um usuário (`ownerId`), já que o app é multi-usuário — cada
/// pessoa rastreia o próprio estoque. `totalCost` é `Money` (não `double`),
/// pelos motivos já documentados em `money.dart`.
///
/// Segue o mesmo padrão de `factory` + construtor privado do resto do
/// domínio: o `factory` valida as invariantes antes de criar o objeto, então
/// se um `Filament` existe na memória, ele é sempre válido.
class Filament extends Equatable {
  final String id;
  final String name;

  // String solta, não uma referência a uma entity `User` — o domínio de
  // usuário foi removido (existia sem invariantes, sem factory e com
  // campos que nada no app usava). Volta como entity de verdade quando a
  // autenticação for implementada.
  final String ownerId;
  final FilamentColor color;
  final FilamentType type;
  final double diameterInMms;
  final Weight weight;
  final Money totalCost;

  /// Construtor privado: só guarda os valores, sem validar nada — quem
  /// valida é sempre o `factory` abaixo.
  const Filament._({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.color,
    required this.type,
    required this.diameterInMms,
    required this.weight,
    required this.totalCost,
  });

  /// Único jeito público de criar um `Filament`. Cada `if` abaixo é uma
  /// invariante da entidade.
  factory Filament({
    required String id,
    required String name,
    required String ownerId,
    required FilamentColor color,
    required FilamentType type,
    required double diameterInMms,
    required Weight weight,
    required Money totalCost,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Id não pode estar vazio.');
    }

    // Nome é o identificador legível do filamento — vazio não faz sentido.
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome do filamento não pode estar vazio.',
      );
    }

    // Multi-usuário: todo Filament precisa pertencer a um dono.
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(
        ownerId,
        'ownerId',
        'O Id do usuário não pode estar vazio.',
      );
    }

    // Diâmetro é uma característica física do filamento (ex: 1.75mm);
    // zero ou negativo não representa um filamento real.
    if (diameterInMms <= 0) {
      throw ArgumentError.value(
        diameterInMms,
        'diameterInMms',
        'O diâmetro deve ser maior que zero.',
      );
    }

    // `Money` permite negativo de propósito (serve pra calcular lucro/
    // prejuízo em Sale) — então essa checagem é responsabilidade do
    // Filament, não do Money em si. Usa o getter `isNegative` já pronto,
    // sem precisar montar um `Money.zero(...)` pra comparar.
    if (totalCost.isNegative) {
      throw ArgumentError.value(
        totalCost,
        'totalCost',
        'O custo do filamento não pode ser inferior a zero.',
      );
    }

    return Filament._(
      id: id,
      name: name,
      ownerId: ownerId,
      color: color,
      type: type,
      diameterInMms: diameterInMms,
      weight: weight,
      totalCost: totalCost,
    );
  }

  /// Registra o consumo de filamento (ex: ao registrar uma impressão).
  ///
  /// Chama o `factory Filament(...)` público, não o construtor privado —
  /// assim TODAS as invariantes são revalidadas (não só o peso), mantendo
  /// a garantia documentada acima ("se um Filament existe, é sempre
  /// válido") mesmo para esse novo Filament derivado. O `-` do `Weight` já
  /// lança erro sozinho se `usedWeight` for maior que o estoque disponível.
  Filament consumeGrams(Weight usedWeight) {
    return Filament(
      id: id,
      name: name,
      ownerId: ownerId,
      color: color,
      type: type,
      diameterInMms: diameterInMms,
      weight: weight - usedWeight,
      totalCost: totalCost,
    );
  }

  // Dois Filament são "iguais" (via Equatable) se todos os campos forem
  // iguais — mesma regra de igualdade por valor usada em todo o domínio
  // (ver `Sale`, `Print`, `Money`, `Weight`).
  @override
  List<Object?> get props => [
    id,
    name,
    ownerId,
    color,
    type,
    diameterInMms,
    weight,
    totalCost,
  ];

  @override
  bool? get stringify => true;
}

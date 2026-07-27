import 'package:equatable/equatable.dart';
import 'package:filament_os/shared/domain/money.dart';

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
  final String ownerId;
  final String color;
  final String type;
  final double diameterInMms;

  // Ainda `double` — vira `Weight` quando esse value object for criado,
  // pelo mesmo motivo de arredondamento do `Money`.
  final double quantityInGrams;

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
    required this.quantityInGrams,
    required this.totalCost,
  });

  /// Único jeito público de criar um `Filament`. Cada `if` abaixo é uma
  /// invariante da entidade.
  factory Filament({
    required String id,
    required String name,
    required String ownerId,
    required String color,
    required String type,
    required double diameterInMms,
    required double quantityInGrams,
    required Money totalCost,
  }) {
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

    // Estoque negativo não existe fisicamente.
    if (quantityInGrams < 0) {
      throw ArgumentError.value(
        quantityInGrams,
        'quantityInGrams',
        'A quantidade do filamento não pode ser negativa',
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
      quantityInGrams: quantityInGrams,
      totalCost: totalCost,
    );
  }

  // Dois Filament são "iguais" (via Equatable) se tiverem mesmo id, name
  // e type — não compara todos os campos, só os que definem identidade
  // pra fins de comparação/teste.
  @override
  List<Object?> get props => [id, name, type];
}

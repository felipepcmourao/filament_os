import 'package:equatable/equatable.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Estoque de um filamento comprado.
class Filament extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final FilamentColor color;
  final FilamentType type;
  final double diameterInMms;
  final Weight weight;
  final Money totalCost;

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

    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome do filamento não pode estar vazio.',
      );
    }

    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(
        ownerId,
        'ownerId',
        'O Id do usuário não pode estar vazio.',
      );
    }

    if (diameterInMms <= 0) {
      throw ArgumentError.value(
        diameterInMms,
        'diameterInMms',
        'O diâmetro deve ser maior que zero.',
      );
    }

    // `Money` aceita negativo de propósito (prejuízo de uma `Sale`), então
    // quem proíbe custo negativo é o `Filament`.
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

  /// Passa pelo `factory` público, e não pelo `_`, para revalidar todas as
  /// invariantes; o `-` do `Weight` já lança se faltar estoque.
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

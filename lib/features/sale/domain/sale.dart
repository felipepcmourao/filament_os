import 'package:equatable/equatable.dart';
import 'package:filament_os/shared/domain/money.dart';

/// O evento de vender uma peça impressa.
///
/// Referencia a impressão vendida via `printId` (não guarda o `Prints`
/// inteiro, mesma lógica de referência-por-id do `Prints` -> `Filament`).
///
/// Não tem `ownerId` próprio: quem é o dono se descobre indiretamente via
/// `Sale.printId -> Prints.ownerId`, evitando duplicar esse dado.
///
/// Não tem campo `isSold`: se um `Sale` existe, ele já É uma venda que
/// aconteceu — um booleano assim seria sempre `true`, portanto redundante.
///
/// `totalCost`/`salePrice` são `Money`, não `double`, pelos mesmos motivos
/// documentados em `money.dart`.
class Sale extends Equatable {
  final String id;
  final String printId;
  final DateTime dateTime;
  final Money totalCost;
  final Money salePrice;

  /// Construtor privado: só guarda os valores, validação já aconteceu
  /// no `factory`.
  const Sale._({
    required this.id,
    required this.printId,
    required this.dateTime,
    required this.totalCost,
    required this.salePrice,
  });

  /// Único jeito público de criar um `Sale`. Cada `if` é uma invariante.
  factory Sale({
    required String id,
    required String printId,
    required DateTime dateTime,
    required Money totalCost,
    required Money salePrice,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Id não pode estar vazio.');
    }

    // Toda venda precisa referenciar qual impressão foi vendida.
    if (printId.trim().isEmpty) {
      throw ArgumentError.value(
        printId,
        'printId',
        'Print Id não pode estar vazio.',
      );
    }

    // Money permite negativo de propósito (serve pra representar prejuízo
    // em cálculos como `salePrice - totalCost`), mas o custo/preço de UMA
    // venda isolada não faz sentido ser negativo — por isso a checagem
    // mora aqui, na entidade, e não dentro do Money.
    if (totalCost.isNegative) {
      throw ArgumentError.value(
        totalCost,
        'totalCost',
        'Custo total não pode ser negativo',
      );
    }
    if (salePrice.isNegative) {
      throw ArgumentError.value(
        salePrice,
        'salePrice',
        'O preço de venda não pode ser negativo.',
      );
    }

    return Sale._(
      id: id.trim(),
      printId: printId.trim(),
      dateTime: dateTime,
      totalCost: totalCost,
      salePrice: salePrice,
    );
  }

  @override
  List<Object?> get props => [id, printId, dateTime, totalCost, salePrice];
}

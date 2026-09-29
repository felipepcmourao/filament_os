import 'package:equatable/equatable.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Um par (filamento usado + quantos gramas) dentro de uma impressão.
///
/// Record, e não duas listas paralelas, para os dois valores não se
/// desencontrarem.
typedef FilamentUsage = ({String filamentId, Weight usedGrams});

/// Uma impressão feita, podendo usar mais de um filamento (multi-material).
///
/// `totalCost` chega calculado por quem cria o `Print` e nunca é recalculado:
/// mudar o preço de um filamento depois não altera impressões antigas.
class Print extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final List<FilamentUsage> filamentUsage;

  // Ainda `double` — só migraria pra um value object (ex: `Duration`) se
  // esse tipo passasse a ter invariantes/comportamento próprio, mesma
  // decisão que motivou `Money` e `Weight`.
  final double printTime;
  final DateTime dateTime;
  final PrintStatus status;
  final Weight finalWeight;
  final Money totalCost;

  const Print._({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.filamentUsage,
    required this.printTime,
    required this.dateTime,
    required this.status,
    required this.finalWeight,
    required this.totalCost,
  });

  factory Print({
    required String id,
    required String name,
    required String ownerId,
    required List<FilamentUsage> filamentUsage,
    required double printTime,
    required DateTime dateTime,
    required PrintStatus status,
    required Weight finalWeight,
    required Money totalCost,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O id da impressão deve estar preenchido.',
      );
    }

    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome da impressão deve estar preenchido.',
      );
    }

    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(
        ownerId,
        'ownerId',
        'É necessário ter um usuário atrelado à impressão.',
      );
    }

    if (filamentUsage.isEmpty) {
      throw ArgumentError.value(
        filamentUsage,
        'filamentUsage',
        'Uma impressão precisa de pelo menos um filamento utilizado e a sua quantidade.',
      );
    }

    // Negativo o `Weight` já barra; aqui falta só o zero.
    if (finalWeight.isZero) {
      throw ArgumentError.value(
        finalWeight,
        'finalWeight',
        'O peso da impressão deve ser maior que zero.',
      );
    }

    if (printTime <= 0) {
      throw ArgumentError.value(
        printTime,
        'printTime',
        'O tempo de impressão deve ser maior que zero.',
      );
    }

    // `Money` aceita negativo de propósito (prejuízo de uma `Sale`), então
    // quem proíbe custo negativo é o `Print`.
    if (totalCost.isNegative) {
      throw ArgumentError.value(
        totalCost,
        'totalCost',
        'O custo de impressão não pode ser negativo.',
      );
    }

    return Print._(
      id: id,
      name: name,
      ownerId: ownerId,
      filamentUsage: filamentUsage,
      printTime: printTime,
      dateTime: dateTime,
      status: status,
      finalWeight: finalWeight,
      totalCost: totalCost,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    ownerId,
    filamentUsage,
    printTime,
    dateTime,
    status,
    finalWeight,
    totalCost,
  ];
}

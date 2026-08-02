import 'package:equatable/equatable.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Um par (filamento usado + quantos gramas) dentro de uma impressão.
///
/// É um Record (recurso do Dart 3), não uma classe própria — serve só pra
/// agrupar esses dois valores relacionados sem risco de desincronização.
/// Antes, isso era duas listas separadas (`usedFilamentIds` e
/// `quantityInGramsPerFilament`) que precisavam ficar do mesmo tamanho e na
/// mesma ordem manualmente; com o Record dentro de uma lista, cada item já
/// carrega os dois valores juntos.
typedef FilamentUsage = ({String filamentId, Weight usedGrams});

/// Uma impressão feita, podendo usar mais de um filamento (multi-material).
///
/// Pertence a um usuário (`ownerId`) e referencia os filamentos usados só
/// pelo `id` (não guarda o `Filament` inteiro) — assim, se o preço de um
/// filamento mudar depois no estoque, o custo de impressões antigas não é
/// afetado retroativamente. `totalCost` é o custo já calculado (proporcional
/// ao quanto foi usado de cada filamento), montado por quem cria o `Print`
/// (ex: `RegisterPrint`), não recalculado aqui.
///
/// Mesmo padrão de `factory` + construtor privado do resto do domínio.
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

  /// Construtor privado: só guarda os valores. A validação já aconteceu
  /// no `factory` antes de chegar aqui.
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

  /// Único jeito público de criar um `Print`. Cada `if` é uma invariante.
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

    // Nome é o identificador legível da impressão.
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome da impressão deve estar preenchido.',
      );
    }

    // Multi-usuário: toda impressão precisa pertencer a um dono.
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(
        ownerId,
        'ownerId',
        'É necessário ter um usuário atrelado à impressão.',
      );
    }

    // Uma impressão sem nenhum filamento usado não representa uma
    // impressão real — precisa de pelo menos um item na lista.
    if (filamentUsage.isEmpty) {
      throw ArgumentError.value(
        filamentUsage,
        'filamentUsage',
        'Uma impressão precisa de pelo menos um filamento utilizado e a sua quantidade.',
      );
    }

    // O próprio `Weight` já impede valor negativo na criação; falta só
    // barrar zero, que também não representa uma peça impressa real.
    if (finalWeight.isZero) {
      throw ArgumentError.value(
        finalWeight,
        'finalWeight',
        'O peso da impressão deve ser maior que zero.',
      );
    }

    // Tempo de impressão zero ou negativo não faz sentido fisicamente.
    if (printTime <= 0) {
      throw ArgumentError.value(
        printTime,
        'printTime',
        'O tempo de impressão deve ser maior que zero.',
      );
    }

    // Mesmo raciocínio do Filament/Sale: Money permite negativo de
    // propósito (serve pra prejuízo em Sale), então essa checagem é
    // responsabilidade do Print, não do Money em si.
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

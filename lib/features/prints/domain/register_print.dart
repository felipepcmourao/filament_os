import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filaments_repository.dart';
import 'package:filament_os/features/prints/domain/print.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/domain/prints_repository.dart';
import 'package:filament_os/shared/domain/app_exception.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Use case: orquestra o registro de uma impressão. Ver ADR 0002.
///
/// `call()` valida e calcula tudo em memória antes da primeira escrita, para
/// nunca deixar o repositório em estado parcial se algo falhar no meio.
class RegisterPrint {
  final FilamentsRepository filamentRepository;
  final PrintsRepository printsRepository;

  RegisterPrint({
    required this.filamentRepository,
    required this.printsRepository,
  });

  Future<Print> call({
    required String printId,
    required String ownerId,
    required PrintStatus status,
    required String name,
    required List<FilamentUsage> filamentUsage,
    required Weight finalWeight,
    required double printTime,
    required DateTime dateTime,
  }) async {
    // Falha cedo e com mensagem clara, em vez de o `totalCost!` lá embaixo
    // quebrar sem explicação.
    if (filamentUsage.isEmpty) {
      throw ArgumentError.value(
        filamentUsage,
        'filamentUsage',
        'Nenhum filamento usado',
      );
    }

    final filamentList = await filamentRepository.list();

    // Nulo, e não `Money.zero`, porque a moeda só se conhece no primeiro
    // item; moeda diferente nos seguintes o `+` já rejeita.
    Money? totalCost;

    // Passada 1, só validação: um `filamentId` inválido no meio da lista não
    // pode deixar os anteriores já debitados.
    for (var e in filamentUsage) {
      final index = filamentList.indexWhere((n) => n.id == e.filamentId);
      if (index == -1) {
        throw FilamentNotFoundException(filamentId: e.filamentId);
      }
    }

    // Passada 2, só cálculo em memória: falta de material num item não pode
    // deixar baixa parcial persistida.
    final List<Filament> listFilamentAfterUse = [];
    for (var e in filamentUsage) {
      final index = filamentList.indexWhere((n) => n.id == e.filamentId);
      final filament = filamentList[index];

      listFilamentAfterUse.add(filament.consumeGrams(e.usedGrams));

      // Custo só da fração usada, proporcional ao peso de ANTES do consumo.
      final cost = filament.totalCost.scaleByRatio(
        e.usedGrams.weightInMilligrams,
        filament.weight.weightInMilligrams,
      );
      totalCost = totalCost == null ? cost : totalCost + cost;
    }

    // `!` seguro: o `if` do início garante que o loop rodou ao menos uma vez.
    final newPrint = Print(
      id: printId,
      name: name,
      ownerId: ownerId,
      filamentUsage: filamentUsage,
      printTime: printTime,
      dateTime: dateTime,
      status: status,
      finalWeight: finalWeight,
      totalCost: totalCost!,
    );

    // Passada 3, só agora persiste.
    // O `Print` vai antes das baixas: se a segunda escrita falhar, só ele
    // permite reconstruir o estoque. Não inverta. Ver ADR 0002.
    await printsRepository.add(newPrint);

    for (var e in listFilamentAfterUse) {
      await filamentRepository.update(e);
    }

    return newPrint;
  }
}

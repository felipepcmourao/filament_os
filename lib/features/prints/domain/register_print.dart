import 'package:filament_os/features/filaments/domain/filament_not_found_exception.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';
import 'package:filament_os/features/prints/domain/print.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Use case: orquestra o registro de uma impressão.
///
/// Diferente de uma entity (`Print`, `Filament`), isso não é uma regra de
/// negócio nova — é quem executa, em ordem, regras que já existem em outro
/// lugar. Depende da ABSTRAÇÃO `FilamentRepository` (não de
/// `FilamentRepositoryFakeImpl` diretamente), recebida via construtor — é
/// essa injeção de dependência que permite trocar a implementação real do
/// repositório sem mudar nada aqui (ver ADR 0002).
///
/// `call()` faz, pra cada filamento usado: (1) encontra o `Filament` real
/// no repositório, (2) debita o estoque (`consumeGrams`, que já valida
/// material suficiente sozinho), (3) calcula o custo proporcional
/// (`scaleByRatio`), (4) persiste o `Filament` atualizado. No fim, soma os
/// custos parciais e devolve um `Print` já validado.
class RegisterPrint {
  final FilamentRepository repository;
  final String printId;
  final String ownerId;
  final PrintStatus status;
  final String name;
  final List<FilamentUsage> filamentUsage;

  // Peso real da peça pronta (sem purga) — não dá pra derivar da soma de
  // `usedGrams`, porque parte do material usado vira desperdício e nunca
  // vira peça. Por isso é recebido de fora, não calculado aqui.
  final Weight finalWeight;
  final double printTime;
  final DateTime dateTime;

  RegisterPrint({
    required this.repository,
    required this.printId,
    required this.dateTime,
    required this.filamentUsage,
    required this.name,
    required this.printTime,
    required this.finalWeight,
    required this.ownerId,
    required this.status,
  });

  Future<Print> call() async {
    // Falha cedo, com uma mensagem clara, em vez de deixar o `totalCost!`
    // no fim do método quebrar de um jeito confuso quando o loop nunca
    // rodar.
    if (filamentUsage.isEmpty) {
      throw ArgumentError.value(
        filamentUsage,
        'filamentUsage',
        'Nenhum filamento usado',
      );
    }

    final filamentList = await repository.list();

    // Começa nulo (em vez de `Money.zero(currency)`) porque ainda não se
    // sabe a moeda até processar o primeiro filamento — a moeda do total
    // acaba sendo a do primeiro item; se algum outro item tiver moeda
    // diferente, o próprio `Money.operator+` já lança
    // `CurrencyMismatchException` sozinho.
    Money? totalCost;

    for (var e in filamentUsage) {
      final index = filamentList.indexWhere((n) => n.id == e.filamentId);
      if (index == -1) {
        throw FilamentNotFoundException(filamentId: e.filamentId);
      }
      final filament = filamentList[index];

      // Novo Filament com o estoque debitado — não muta o `filament`
      // original (tudo é imutável). `consumeGrams` já lança erro sozinho
      // se `e.usedGrams` for maior que o estoque disponível.
      final filamentAfterUse = filament.consumeGrams(e.usedGrams);

      // Custo só da fração usada, não do filamento inteiro: proporção
      // entre o quanto foi usado e o quanto o filamento tinha ANTES de
      // consumir.
      final cost = filament.totalCost.scaleByRatio(
        e.usedGrams.weightInMiligrams,
        filament.weightInGrams.weightInMiligrams,
      );
      totalCost = totalCost == null ? cost : totalCost + cost;

      // Persiste a baixa de estoque de volta no repositório.
      await repository.update(filamentAfterUse);
    }

    // Seguro usar `!` aqui: o `if` lá em cima já garante que o loop
    // acima rodou pelo menos uma vez, então `totalCost` nunca chega
    // `null` até este ponto (o Dart só não consegue provar isso sozinho).
    return Print(
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
  }
}

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

    // Passada 3, só agora persiste: só chega aqui se a validação (passada
    // 1) e o cálculo (passada 2) terminaram sem lançar nada.
    //
    // O `Print` é gravado ANTES das baixas de estoque, e a ordem não é
    // acidental. As duas escritas não são atômicas — não há transação por
    // trás delas — então uma pode falhar depois da outra ter sido gravada,
    // e a escolha aqui é sobre QUAL das duas inconsistências sobra:
    //
    // - Print gravado, baixas não: o estoque fica alto demais, mas o
    //   `filamentUsage` do Print diz exatamente quais filamentos e quantos
    //   gramas — dá pra refazer a baixa a partir dele.
    // - Baixas gravadas, Print não: sumiu material do estoque e não existe
    //   nada no app explicando pra onde foi. O nome, o tempo e o custo da
    //   impressão não estão em lugar nenhum — não há como reconstruir.
    //
    // O `Print` é o evento (o fato que aconteceu); o estoque é estado
    // derivado dele. Grava-se o evento primeiro, porque só ele reconstrói
    // o outro lado. Não inverta sem reler isto.
    //
    // O conserto de verdade é fazer as duas escritas numa única operação
    // atômica (transação/batch do Firestore, equivalente no Hive). Enquanto
    // os repositórios forem listas em memória, escolher a ordem é tudo o
    // que dá pra fazer.
    await printsRepository.add(newPrint);

    for (var e in listFilamentAfterUse) {
      await filamentRepository.update(e);
    }

    return newPrint;
  }
}

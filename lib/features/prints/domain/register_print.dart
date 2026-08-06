import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_not_found_exception.dart';
import 'package:filament_os/features/filaments/domain/filament_repository.dart';
import 'package:filament_os/features/prints/domain/print.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/domain/prints_repository.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

/// Use case: orquestra o registro de uma impressão.
///
/// Diferente de uma entity (`Print`, `Filament`), isso não é uma regra de
/// negócio nova — é quem executa, em ordem, regras que já existem em outro
/// lugar. Depende das ABSTRAÇÕES `FilamentRepository` e `PrintsRepository`
/// (não das implementações concretas), recebidas via construtor — é essa
/// injeção de dependência que permite trocar a persistência real sem mudar
/// nada aqui (ver ADR 0002). Ambas vêm pelo construtor, e não como parâmetro
/// do `call()`, porque este use case sempre trabalha com as duas: o que muda
/// com o tempo é a implementação, nunca o contrato.
///
/// `call()` separa cálculo de escrita, nessa ordem, pra nunca deixar o
/// repositório num estado parcial se algo falhar no meio do caminho:
/// (1) valida que todo `filamentId` existe no repositório — lança
/// `FilamentNotFoundException` antes de qualquer `Filament` ser alterado;
/// (2) calcula, só em memória, o `Filament` com estoque debitado
/// (`consumeGrams`, que já valida material suficiente sozinho) e o custo
/// proporcional (`scaleByRatio`) de cada item — se algum item não tiver
/// material suficiente, nada ainda foi persistido;
/// (3) só depois que (1) e (2) terminam sem erro, escreve: primeiro o
/// `Print`, depois as baixas de estoque.
///
/// A ordem entre essas duas escritas é deliberada — ver o comentário no
/// corpo do método antes de inverter.

class RegisterPrint {
  final FilamentRepository filamentRepository;
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

    final filamentList = await filamentRepository.list();

    // Começa nulo (em vez de `Money.zero(currency)`) porque ainda não se
    // sabe a moeda até processar o primeiro filamento — a moeda do total
    // acaba sendo a do primeiro item; se algum outro item tiver moeda
    // diferente, o próprio `Money.operator+` já lança
    // `CurrencyMismatchException` sozinho.
    Money? totalCost;

    // Passada 1, só validação: confere que todo filamentId existe ANTES de
    // debitar ou persistir qualquer coisa. Se essa checagem estivesse
    // dentro do loop de baixa de estoque (passada 2), um filamentId
    // inválido no meio da lista deixaria os filamentos anteriores já
    // debitados no repositório.
    for (var e in filamentUsage) {
      final index = filamentList.indexWhere((n) => n.id == e.filamentId);
      if (index == -1) {
        throw FilamentNotFoundException(filamentId: e.filamentId);
      }
    }

    // Passada 2, só cálculo em memória: nenhuma chamada ao repositório
    // aqui dentro. Isso garante que, se `consumeGrams` lançar erro por
    // material insuficiente em algum item, nenhum `Filament` já tenha
    // sido persistido com baixa de estoque parcial.
    final List<Filament> listFilamentAfterUse = [];
    for (var e in filamentUsage) {
      final index = filamentList.indexWhere((n) => n.id == e.filamentId);
      final filament = filamentList[index];

      // Novo Filament com o estoque debitado — não muta o `filament`
      // original (tudo é imutável). `consumeGrams` já lança erro sozinho
      // se `e.usedGrams` for maior que o estoque disponível.
      listFilamentAfterUse.add(filament.consumeGrams(e.usedGrams));

      // Custo só da fração usada, não do filamento inteiro: proporção
      // entre o quanto foi usado e o quanto o filamento tinha ANTES de
      // consumir.
      final cost = filament.totalCost.scaleByRatio(
        e.usedGrams.weightInMiligrams,
        filament.weightInGrams.weightInMiligrams,
      );
      totalCost = totalCost == null ? cost : totalCost + cost;
    }

    // Seguro usar `totalCost!` aqui: o `if` lá em cima já garante que o
    // loop acima rodou pelo menos uma vez, então `totalCost` nunca chega
    // `null` até este ponto (o Dart só não consegue provar isso sozinho).
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

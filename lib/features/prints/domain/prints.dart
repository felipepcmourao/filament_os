/// Um par (filamento usado + quantos gramas) dentro de uma impressão.
///
/// É um Record (recurso do Dart 3), não uma classe própria — serve só pra
/// agrupar esses dois valores relacionados sem risco de desincronização.
/// Antes, isso era duas listas separadas (`usedFilamentIds` e
/// `quantityInGramsPerFilament`) que precisavam ficar do mesmo tamanho e na
/// mesma ordem manualmente; com o Record dentro de uma lista, cada item já
/// carrega os dois valores juntos.
typedef FilamentUsage = ({String filamentId, double usedGrams});

/// Uma impressão feita, podendo usar mais de um filamento (multi-material).
///
/// Pertence a um usuário (`ownerId`) e referencia os filamentos usados só
/// pelo `id` (não guarda o `Filament` inteiro) — assim, se o preço de um
/// filamento mudar depois no estoque, o custo de impressões antigas não é
/// afetado retroativamente.
///
/// Mesmo padrão de `factory` + construtor privado do resto do domínio.
class Prints {
  final String id;
  final String name;
  final String ownerId;
  final List<FilamentUsage> filamentUsage;

  // Ainda `double` — vira `Weight`/`Duration` quando esses value objects
  // forem migrados, mesmo raciocínio do `Filament.quantityInGrams`.
  final double printTime;
  final DateTime dateTime;
  final String status;
  final double finalWeight;

  /// Construtor privado: só guarda os valores. A validação já aconteceu
  /// no `factory` antes de chegar aqui.
  Prints._({
    required this.dateTime,
    required this.name,
    required this.ownerId,
    required this.filamentUsage,
    required this.printTime,
    required this.finalWeight,
    required this.id,
    required this.status,
  });

  /// Único jeito público de criar um `Prints`. Cada `if` é uma invariante.
  factory Prints({
    required String id,
    required String name,
    required String ownerId,
    required List<FilamentUsage> filamentUsage,
    required double printTime,
    required DateTime dateTime,
    required String status,
    required double finalWeight,
  }) {
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

    // Peso final zero ou negativo não representa uma peça impressa real.
    if (finalWeight <= 0) {
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

    return Prints._(
      dateTime: dateTime,
      name: name,
      ownerId: ownerId,
      filamentUsage: filamentUsage,
      printTime: printTime,
      finalWeight: finalWeight,
      id: id,
      status: status,
    );
  }
}

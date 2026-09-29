import 'package:equatable/equatable.dart';

/// Value object de peso.
///
/// Guarda o valor como miligramas (`int`), não como gramas (`double`), pelo
/// mesmo motivo do `Money`: impressão 3D usa valores decimais (ex: 298,60g)
/// e somar/subtrair muitos `double` ao longo do tempo acumula erro de
/// arredondamento — um `int` não tem esse problema.
///
/// É imutável: toda operação (`+`, `-`) devolve uma instância NOVA, nunca
/// modifica a atual.
class Weight extends Equatable {
  final int weightInMilligrams;

  /// Construtor privado: só guarda o valor, sem validar — quem valida é
  /// sempre o `factory` abaixo.
  const Weight._({required this.weightInMilligrams});

  /// Único jeito público de criar um `Weight`. Um peso negativo não existe
  /// fisicamente, então essa é a única invariante — zero é permitido (ex:
  /// um Filament pode ficar sem estoque sem deixar de existir).
  factory Weight({required int weightInMilligrams}) {
    if (weightInMilligrams < 0) {
      throw ArgumentError.value(
        weightInMilligrams,
        'weightInMilligrams',
        'O peso não pode ser negativo.',
      );
    }
    return Weight._(weightInMilligrams: weightInMilligrams);
  }

  /// Atalho pra um `Weight` zerado, útil pra comparações (ex: `isZero`).
  factory Weight.zero() {
    return Weight(weightInMilligrams: 0);
  }

  /// Converte um valor em gramas (a unidade real, digitada pelo usuário ou
  /// lida de uma balança) pro miligramas internos. Centraliza essa conta
  /// aqui pra não repetir `* 1000` em cada lugar que recebe gramas.
  factory Weight.fromGrams({required double weight}) {
    return Weight(weightInMilligrams: (weight * 1000).round());
  }

  Weight operator +(Weight other) {
    return Weight(
      weightInMilligrams: weightInMilligrams + other.weightInMilligrams,
    );
  }

  // Chama o `factory` (não o construtor privado), então se o resultado for
  // negativo (consumiu mais do que existia), o próprio `Weight` já lança
  // o erro — quem chama não precisa checar isso antes de subtrair.
  Weight operator -(Weight other) {
    return Weight(
      weightInMilligrams: weightInMilligrams - other.weightInMilligrams,
    );
  }

  bool operator >(Weight other) {
    return weightInMilligrams > other.weightInMilligrams;
  }

  bool operator <(Weight other) {
    return weightInMilligrams < other.weightInMilligrams;
  }

  bool operator <=(Weight other) {
    return weightInMilligrams <= other.weightInMilligrams;
  }

  bool operator >=(Weight other) {
    return weightInMilligrams >= other.weightInMilligrams;
  }

  // Volta pra gramas (a unidade que faz sentido mostrar na tela). Divisão
  // de int por int com `/` já devolve `double` em Dart, sem precisar de
  // nenhuma conversão extra.
  double get toGrams => weightInMilligrams / 1000;

  // Não existe `isNegative`: o `factory` já impede um Weight negativo de
  // existir, então esse getter nunca teria utilidade real.
  bool get isPositive => weightInMilligrams > 0;
  bool get isZero => weightInMilligrams == 0;

  @override
  List<Object?> get props => [weightInMilligrams];

  @override
  bool? get stringify => true;
}

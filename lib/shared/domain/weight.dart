import 'package:equatable/equatable.dart';

/// Value object de peso, nunca negativo.
///
/// Guarda miligramas em `int`, e não gramas em `double`, pra que somas
/// sucessivas não acumulem erro de arredondamento. Ver ADR 0005.
class Weight extends Equatable {
  final int weightInMilligrams;

  const Weight._({required this.weightInMilligrams});

  /// Cria um peso em miligramas e lança `ArgumentError` se for negativo.
  /// Zero é válido: um filamento sem estoque continua existindo.
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

  /// Atalho pra um `Weight` zerado.
  factory Weight.zero() {
    return Weight(weightInMilligrams: 0);
  }

  /// Cria um peso a partir de gramas, a unidade digitada pelo usuário.
  factory Weight.fromGrams({required double weightInGrams}) {
    return Weight(weightInMilligrams: (weightInGrams * 1000).round());
  }

  Weight operator +(Weight other) {
    return Weight(
      weightInMilligrams: weightInMilligrams + other.weightInMilligrams,
    );
  }

  // Passa pelo `factory` de propósito: consumir mais do que existe lança
  // erro aqui mesmo, e quem chama não precisa checar o saldo antes.
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

  double get toGrams => weightInMilligrams / 1000;

  bool get isPositive => weightInMilligrams > 0;
  bool get isZero => weightInMilligrams == 0;

  @override
  List<Object?> get props => [weightInMilligrams];

  @override
  bool? get stringify => true;
}

import 'package:equatable/equatable.dart';
import 'package:filament_os/shared/domain/currency_mismatch_exception.dart';

/// Value object de dinheiro.
///
/// Guarda o valor como centavos (`int`), não como reais (`double`), pra evitar
/// erro de arredondamento binário quando muitos valores são somados (ex: no
/// Dashboard, somando várias vendas). Também guarda a moeda, pra permitir
/// expansão futura pra outros países sem precisar migrar dado já existente —
/// mas sem lógica de conversão de câmbio, que não é usada ainda.
///
/// É imutável: toda operação (`+`, `-`, `scaleByRatio`) devolve uma instância
/// NOVA, nunca modifica a atual.
class Money extends Equatable {
  // ---------------------------------------------------------------------
  // Campos
  // ---------------------------------------------------------------------

  final int amountInCents;
  final String currency;

  // ---------------------------------------------------------------------
  // Construção
  // ---------------------------------------------------------------------

  /// Construtor privado (o `_` esconde ele fora deste arquivo). Só guarda os
  /// valores — não valida nada, porque quem chama (o `factory` abaixo) já
  /// validou antes de delegar pra cá.
  const Money._({required this.amountInCents, required this.currency});

  /// Único jeito público de criar um `Money`. Valida que a moeda não é vazia
  /// antes de criar o objeto — assim, se um `Money` existe, ele é sempre
  /// válido (não precisa checar isso de novo em nenhum outro lugar do app).
  ///
  /// `currency.trim()` é salvo (não o valor cru) pra garantir que
  /// `' BRL '` e `'BRL'` sejam tratados como a mesma moeda em toda a classe
  /// (comparações, `Equatable`, etc.) — o trim acontece uma única vez, aqui.
  factory Money({required int amountInCents, required String currency}) {
    if (currency.trim().isEmpty) {
      throw ArgumentError.value(
        currency,
        'currency',
        'A moeda precisa ser definida.',
      );
    }
    return Money._(amountInCents: amountInCents, currency: currency.trim());
  }

  /// Atalho pra criar um `Money` zerado numa moeda específica. Útil pra
  /// comparar sinais (lucro/prejuízo) sem comparar contra um `int 0` solto,
  /// que não teria moeda e quebraria a checagem de `_assertSameCurrency`.
  factory Money.zero(String currency) {
    return Money(amountInCents: 0, currency: currency);
  }

  // ---------------------------------------------------------------------
  // Regra interna: duas moedas diferentes não podem ser combinadas
  // ---------------------------------------------------------------------

  /// Lança `CurrencyMismatchException` se `other` for de uma moeda diferente.
  /// Chamado no início de todo operador que combina/compara dois `Money`,
  /// pra não repetir esse `if` em cada um deles.
  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(
        expectedCurrency: currency,
        actualCurrency: other.currency,
      );
    }
  }

  // ---------------------------------------------------------------------
  // Operadores aritméticos — devolvem um Money novo
  // ---------------------------------------------------------------------

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(
      amountInCents: amountInCents + other.amountInCents,
      currency: currency,
    );
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(
      amountInCents: amountInCents - other.amountInCents,
      currency: currency,
    );
  }

  // ---------------------------------------------------------------------
  // Operadores de comparação — devolvem bool, não criam Money novo
  // ---------------------------------------------------------------------

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amountInCents > other.amountInCents;
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amountInCents < other.amountInCents;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return amountInCents <= other.amountInCents;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return amountInCents >= other.amountInCents;
  }

  // ---------------------------------------------------------------------
  // Proporção — pra calcular o custo de uma FRAÇÃO de um valor total
  // ---------------------------------------------------------------------

  /// Multiplica antes de dividir (`amountInCents * numerator ~/ denominator`)
  /// pra perder o mínimo de precisão possível — dividir primeiro arredonda
  /// "cedo" e esse erro se multiplica depois. Não sabe o que é "grama": só
  /// faz matemática de razão, pra continuar reutilizável em qualquer proporção
  /// (quem chama decide de onde vêm `numerator`/`denominator`).
  Money scaleByRatio(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominador deve ser diferente de zero.');
    }
    return Money(
      amountInCents: amountInCents * numerator ~/ denominator,
      currency: currency,
    );
  }

  // ---------------------------------------------------------------------
  // Sinal — pra checar lucro (positivo) / prejuízo (negativo) / nada (zero)
  // ---------------------------------------------------------------------

  bool get isPositive => amountInCents > 0;
  bool get isNegative => amountInCents < 0;
  bool get isZero => amountInCents == 0;

  // ---------------------------------------------------------------------
  // Igualdade por valor (Equatable) — dois Money são "iguais" se tiverem
  // o mesmo valor em centavos E a mesma moeda, mesmo sendo instâncias
  // diferentes na memória.
  // ---------------------------------------------------------------------

  @override
  List<Object?> get props => [amountInCents, currency];

  @override
  String toString() {
    return '$currency ${(amountInCents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

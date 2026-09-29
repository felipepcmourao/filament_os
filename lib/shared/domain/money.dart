import 'package:equatable/equatable.dart';
import 'package:filament_os/shared/domain/app_exception.dart';

/// Value object de dinheiro, sempre com moeda definida.
///
/// Guarda centavos em `int` pelo mesmo motivo do `Weight`, e a moeda junto
/// para aceitar outros países sem migrar dado já salvo. Ver ADR 0005.
class Money extends Equatable {
  final int amountInCents;
  final String currency;

  const Money._({required this.amountInCents, required this.currency});

  /// Lança `ArgumentError` se a moeda for vazia. Guarda a moeda sem espaços
  /// nas pontas, para que `' BRL '` e `'BRL'` sejam a mesma moeda.
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

  factory Money.zero(String currency) {
    return Money(amountInCents: 0, currency: currency);
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(
        expectedCurrency: currency,
        actualCurrency: other.currency,
      );
    }
  }

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

  /// Multiplica antes de dividir para arredondar uma vez só, no fim. Não
  /// conhece gramas de propósito: quem chama decide de onde vem a razão.
  Money scaleByRatio(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominador deve ser diferente de zero.');
    }
    return Money(
      amountInCents: amountInCents * numerator ~/ denominator,
      currency: currency,
    );
  }

  bool get isPositive => amountInCents > 0;
  bool get isNegative => amountInCents < 0;
  bool get isZero => amountInCents == 0;

  @override
  List<Object?> get props => [amountInCents, currency];

  @override
  bool? get stringify => true;
}

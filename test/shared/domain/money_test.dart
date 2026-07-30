
import 'package:filament_os/shared/domain/currency_mismatch_exception.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verificar se dados são registrados corretamente.', () {
    final money = Money(amountInCents: 50000, currency: 'BRL');

    expect(money.amountInCents, 50000);
    expect(money.currency, 'BRL');
  });

  test('Lançar exceção ao tentar somar duas moedas diferentes', (){
    final moneyEUR = Money(amountInCents: 100, currency: 'EUR');
    final moneyBRL = Money(amountInCents: 100, currency: 'BRL');
    expect(()=> moneyBRL + moneyEUR
    , throwsA(isA<CurrencyMismatchException>()));
  });
}

/// Erro lançado quando dois `Money` de moedas diferentes são combinados
/// (ex: somar BRL com EUR).
///
/// É uma exceção customizada, não um `ArgumentError` genérico, porque é uma
/// categoria de erro diferente: `ArgumentError` serve pra "esse valor,
/// sozinho, é inválido" (ex: peso negativo); aqui, os dois `Money` são cada
/// um válido por si só — o problema é que não podem ser combinados na
/// mesma operação. Separar os dois permite tratar cada categoria de forma
/// diferente em quem capturar o erro (`try`/`catch`) mais pra frente.
class CurrencyMismatchException implements Exception {
  final String expectedCurrency;
  final String actualCurrency;

  CurrencyMismatchException({
    required this.expectedCurrency,
    required this.actualCurrency,
  });

  // Sem isso, um erro não tratado apareceria no console só como
  // "Instance of 'CurrencyMismatchException'" — sem dizer qual moeda
  // era esperada e qual foi recebida.
  @override
  String toString() {
    return 'Moedas incompatíveis. Moeda esperada: $expectedCurrency. Moeda fornecida: $actualCurrency';
  }
}

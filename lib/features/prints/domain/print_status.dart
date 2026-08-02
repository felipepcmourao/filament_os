/// Estados possíveis de uma impressão (`Print`).
///
/// Fica em `prints/domain` (não em `shared/domain`) pelo mesmo motivo de
/// `FilamentColor`/`FilamentType`: é vocabulário específico do `Print`, não
/// um conceito compartilhado entre features.
enum PrintStatus {
  printing('Imprimindo'),
  successful('Sucesso'),
  fail('Falha');

  final String label;
  const PrintStatus(this.label);

  @override
  String toString() => label;
}

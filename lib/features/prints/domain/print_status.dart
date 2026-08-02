enum PrintStatus {
  printing('Imprimindo'),
  successful('Sucesso'),
  fail('Falha');

  final String label;
  const PrintStatus(this.label);

  @override
  String toString() => label;
}

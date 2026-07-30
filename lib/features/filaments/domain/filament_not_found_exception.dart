/// Erro lançado quando um `filamentId` referenciado (ex: dentro de um
/// `FilamentUsage`, ao registrar uma impressão) não corresponde a nenhum
/// `Filament` existente. Mesma categoria de erro dos outros dois
/// `FilamentNot*Exception` — uma referência que não resolveu, não um
/// valor inválido em si.
class FilamentNotFoundException implements Exception {
  final String filamentId;

  FilamentNotFoundException({required this.filamentId});

  @override
  String toString() {

    return 'Filamento de ID $filamentId não foi encontrado.';
  }
}
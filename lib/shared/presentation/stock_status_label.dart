import 'package:filament_os/shared/domain/stock_status.dart';

/// Nome exibido de cada nível de estoque.
///
/// Mesmo padrão de `FilamentColorLabel`. Fica em `shared/presentation`, e não
/// dentro de uma feature, porque acompanha o `StockStatus` — que é
/// compartilhado entre features pelos motivos descritos lá.
///
/// Está separado de `StockStatusMaterial`, no arquivo ao lado, porque são
/// duas perguntas distintas sobre o mesmo enum: "que texto isto mostra" e
/// "que cor isto tem". Juntar as duas faria o nome de qualquer um dos dois
/// arquivos deixar de descrever o que ele faz.
extension StockStatusLabel on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.low:
        return 'Baixo';
      case StockStatus.healthy:
        return 'Saudável';
      case StockStatus.exhausted:
        return 'Esgotado';
    }
  }
}

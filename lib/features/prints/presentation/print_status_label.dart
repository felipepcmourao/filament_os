import 'package:filament_os/features/prints/domain/print_status.dart';

/// Nome exibido de cada estado de impressão.
///
/// Substantivos ('Falha', não 'Falhou'): rotulam o estado atual da
/// impressão, não o evento que a colocou nele.
extension PrintStatusLabel on PrintStatus {
  String get label {
    switch (this) {
      case PrintStatus.fail:
        return 'Falha';
      case PrintStatus.printing:
        return 'Imprimindo';
      case PrintStatus.successful:
        return 'Sucesso';
    }
  }
}

import 'package:filament_os/features/filaments/domain/filament_color.dart';

/// Nome exibido de cada cor de filamento.
///
/// Mora na presentation, e não dentro do enum, porque 'Vermelho' é texto de
/// UI: muda quando o idioma do app mudar. O teste que separa domínio de
/// apresentação é esse — `FilamentColor.red` é o conceito e nunca muda;
/// 'Vermelho' vira 'Red'.
///
/// É `extension` com `switch` exaustivo e sem `default` pelo mesmo motivo de
/// `FilamentColorMaterial` (ver ADR 0003): uma cor nova no enum não compila
/// enquanto não for mapeada aqui, então o esquecimento aparece no build.
///
/// É getter, e não método `toLabel()`, porque não recebe argumento nem
/// calcula nada — a chamada fica `filament.color.label`, idêntica a quando o
/// campo ainda morava no enum. Só a camada de origem mudou.
///
/// Quando a internacionalização entrar (o `intl` já está no `pubspec.yaml`),
/// estas strings saem daqui para os arquivos de tradução e o getter passa a
/// buscá-las de lá — quem chama não muda.
extension FilamentColorLabel on FilamentColor {
  String get label {
    switch (this) {
      case FilamentColor.blue:
        return 'Azul';
      case FilamentColor.green:
        return 'Verde';
      case FilamentColor.grey:
        return 'Cinza';
      case FilamentColor.pink:
        return 'Rosa';
      case FilamentColor.red:
        return 'Vermelho';
      case FilamentColor.yellow:
        return 'Amarelo';
    }
  }
}

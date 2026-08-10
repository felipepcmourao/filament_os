import 'package:filament_os/shared/domain/weight.dart';

/// Texto exibido de um peso.
///
/// Mora na presentation, e não em `Weight.toString()`, pelo mesmo teste que
/// tirou os labels dos enums: '450 gramas' muda quando o idioma do app mudar,
/// e o peso em si não. Mas aqui havia um agravante que os enums não tinham —
/// em Dart, `toString()` é ferramenta de **debug**: é o que aparece em log,
/// stack trace e mensagem de exceção, e é chamado sozinho pelo `print`, pelo
/// `assert` e por qualquer interpolação. Enquanto ele formatava para a tela,
/// dois consumidores com necessidades opostas dependiam do mesmo método, e um
/// dos dois sempre recebia a saída errada. `Weight.toString()` voltou a ser
/// diagnóstico (via `stringify` do Equatable, que devolve `Weight(450000)`,
/// em miligramas, a unidade real do campo) e a formatação de tela veio para cá.
///
/// Fica em `shared/presentation`, e não dentro de uma feature, porque
/// acompanha o `Weight` — que é compartilhado, pelos motivos da ADR 0005.
/// Mesmo formato de `StockStatusLabel` e `FilamentColorLabel`: getter `label`,
/// não método `toLabel()`, porque não recebe argumento — a chamada fica
/// `filament.weightInGrams.label`, idêntica às vizinhas no mesmo `Row`.
///
/// Três decisões de apresentação estão tomadas aqui, e nenhuma delas se
/// reconstrói lendo o código:
///
/// 1. **Duas casas decimais** é o formato em que os slicers reportam consumo
///    de filamento (`XXXX,XX`), que é a referência com que o usuário deste app
///    já convive. Não é a precisão de armazenamento: o `Weight` guarda
///    miligramas, e o análogo exato do `Money` (que guarda centavos e mostra
///    duas casas) seriam três casas aqui, não duas.
/// 2. **`,00` é descartado**, para um peso que é número inteiro de gramas não
///    exibir precisão que ele não tem. `450 gramas`, não `450,00 gramas`.
/// 3. **Peso zero vira `'Sem estoque'`**, não `'0 gramas'` nem um traço. Um
///    traço funcionaria na `FilamentsPage`, onde o badge 'Esgotado' ao lado dá
///    o contexto — mas a `FilamentDetailsPage` mostra três `Text` soltos, sem
///    badge nenhum, e ali um `-` não diria nada. O texto tem que se sustentar
///    sozinho, então ele carrega o significado em vez de depender do vizinho.
///    É também o único ramo que devolve uma frase completa em vez de um número
///    esperando unidade — por isso sai por um `return` próprio, e não pelo
///    caminho compartilhado que concatena `' gramas'`.
///
/// Limitação conhecida, para a sessão de internacionalização: não há regra de
/// plural, então 1000 miligramas imprime `1 gramas`. O conserto é o mesmo
/// destas strings — `NumberFormat`/`intl` e arquivos de tradução, com o getter
/// passando a buscar o texto de lá. Quem chama não muda.
extension WeightLabel on Weight {
  String get label {
    String weightLabel;
    if (isZero) {
      return 'Sem estoque';
    } else if (weightInMiligrams % 1000 == 0) {
      weightLabel = toGrams.toStringAsFixed(0);
    } else {
      weightLabel = toGrams.toStringAsFixed(2).replaceAll('.', ',');
    }
    return '$weightLabel gramas';
  }
}

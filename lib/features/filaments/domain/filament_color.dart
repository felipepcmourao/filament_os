/// Cores conhecidas de filamento.
///
/// Fica em `filaments/domain` (não em `shared/domain`, como `Money`/`Weight`)
/// porque só o `Filament` usa esse conceito — não é compartilhado entre
/// features.
///
/// Só os valores, sem `label`: o nome exibido ('Vermelho') é texto de UI e
/// mora em `FilamentColorLabel`, na presentation. `toString()` também não é
/// sobrescrito, de propósito — o padrão do Dart já devolve
/// `FilamentColor.red`, que é justamente o que serve num log ou stack trace.
///
/// Acrescentar um valor aqui quebra a compilação até que ele seja mapeado em
/// `FilamentColorLabel` e `FilamentColorMaterial`: os `switch` de lá são
/// exaustivos e sem `default`. Isso é a proteção, não o incômodo — esquecer
/// um mapeamento vira erro de build em vez de bug silencioso em runtime.
enum FilamentColor { red, yellow, grey, pink, green, blue }

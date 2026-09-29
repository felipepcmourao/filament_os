# CLAUDE.md

## Modo de trabalho (leia antes de qualquer coisa)

Este repositório é um **projeto de estudo com autoria humana**. O objetivo não é o código pronto — é o aprendizado de quem escreve. Portanto:

- **Não implemente por conta própria.** O padrão é guiar com perguntas socráticas, revisar o que já foi escrito e explicar o *porquê* das decisões.
- **Mesmo quando for pedido para mudar o código**, se parecer algo que a pessoa consegue resolver sozinha, dê pistas primeiro. Só implemente direto se ela continuar travada depois de tentar.
- Cansaço ("estou cansado, me mostra como faz") **não** é permissão para assumir a autoria. Ofereça escopo menor ("quer que eu destrave só a parte X e você escreve o resto?") antes de escrever qualquer coisa.
- O que é aceitável escrever direto, quando pedido: valores puramente estéticos (tons de cor, espaçamentos), comentários, mensagens de commit e formatação.
- Explique todo termo técnico na primeira vez que aparecer. Nada de jargão solto.

## Comandos

```bash
flutter analyze   # precisa terminar sem NENHUM erro ou warning
flutter test      # precisa passar inteiro
flutter run
```

Ambos são critério de aprovação de toda sessão — rode os dois antes de considerar qualquer trabalho concluído.

## Arquitetura

**Feature-first + Clean Architecture em vertical slice.** Cada feature em `lib/features/<feature>/` tem até quatro camadas:

- `domain/` — entities, value objects, enums, exceções e use cases. **Zero imports de Flutter ou de infraestrutura.**
- `data/` — implementações concretas dos repositórios.
- `di/` — providers Riverpod que ligam uma abstração (repositório, use case) à sua implementação concreta. Só injeção — estado de tela não mora aqui, mora em `presentation/`. Existe pra `presentation/` nunca precisar importar `data/` diretamente (ver [ADR 0007](docs/adr/0007-gerenciamento-de-estado.md)).
- `presentation/` — widgets, páginas e extensions que traduzem domínio → Material.

`lib/shared/` guarda o que é reutilizável entre features (`Money`, `Weight`, `StockStatus`). `lib/core/` guarda infraestrutura transversal (tema, rotas, config) — não pertence a nenhuma feature.

**Regra central:** nenhuma feature pode importar a `presentation` de outra feature. O desacoplamento acontece por rota, não por import.

As decisões estruturais estão documentadas em [docs/adr/](docs/adr/) — leia antes de propor mudança de estrutura, e escreva uma ADR nova quando uma decisão dessas for tomada.

## Convenções do domínio

- **`factory` + construtor privado.** Toda entity (`Filament`, `Print`, `Sale`) e value object (`Money`, `Weight`) tem construtor privado `_` que só guarda valores, e um `factory` público que valida as invariantes. Se um objeto existe em memória, ele é válido — ninguém precisa revalidar depois.
- **Value objects em vez de primitivos** para grandezas com regra própria. `Money` guarda centavos e `Weight` guarda miligramas, ambos como `int`, para não acumular erro de arredondamento.
- **Imutabilidade.** Operações devolvem instância nova (`consumeGrams`, `operator +`), nunca mutam.
- **`Equatable`** para igualdade por valor em todo o domínio.
- **Exceções tipadas** (`FilamentNotFoundException`, `CurrencyMismatchException`) em vez de `String` de mensagem cruzando camadas.
- **Nenhuma decisão de apresentação mora no `domain/`.** São cinco: idioma, unidade, separador decimal, precisão e formato. Vale para todo o domínio — enum, value object, entity —, sem exceção, nem quando o texto não muda com o idioma (`'PLA'` também mora na presentation). Uma regra sem ressalva é mais fácil de seguir do que uma que exige decidir caso a caso. A regra já foi aprendida duas vezes por engano: primeiro no campo `label` dos enums, depois no `toString()` de `Money`, `Weight` e `Filament`, que formatavam `'EUR 10,00'` e `'450 gramas'` e eram renderizados direto pela tela. Escrita larga assim para não haver terceira.
- **`toString()` é diagnóstico, nunca texto de tela.** Em Dart ele é chamado *sozinho* pelo `print`, pelo `assert`, pelo painel de debug e por qualquer interpolação numa mensagem de exceção — o consumidor dele é quem lê log e stack trace. Uma tela que precisa de texto chama um método explícito, e por isso é sempre ela que muda de lugar, nunca o contrário. No domínio: enum não sobrescreve `toString()` (o padrão do Dart já devolve `FilamentColor.blue`); value object e entity usam `stringify => true` do `Equatable`, que devolve `Weight(450000)` e `Money(1000, EUR)` — na unidade guardada, sem idioma e sem separador.
- **Toda tradução domínio → UI mora numa `extension` na `presentation`.** Duas famílias: `*Label` (getter `label`, devolve o texto exibido) e `*Material` (devolve `Color`/tokens). Sobre enum, o `switch` é exaustivo e **sem `default`**, para que um valor novo sem mapeamento quebre em tempo de compilação e não em runtime. Ver `FilamentColorLabel`, `StockStatusMaterial` e — sobre classe, não enum — `WeightLabel`. É getter e não método `toX()` porque não recebe argumento: a chamada fica `filament.weight.label`, idêntica às vizinhas. Extension é opt-in por import, então quem não importa não enxerga o texto.
- **Onde a extension mora acompanha o tipo que ela traduz**, não a tela que a usa: `FilamentColorLabel` em `features/filaments/presentation/`, `StockStatusLabel` e `WeightLabel` em `shared/presentation/`.
- **A extension só nasce quando uma tela precisa dela.** `Money` e `Filament` não têm `*Label` porque nenhuma tela os exibe hoje — é o mesmo "domínio enxuto" do item abaixo, aplicado à presentation.
- **A escolha de formato vai escrita no doc-comment da extension**, com o porquê. `WeightLabel` mostra duas casas decimais porque é o formato em que os slicers reportam consumo de filamento, descarta o `,00` em grama inteira, e devolve `'Sem estoque'` em vez de `'0 gramas'` — nenhuma das três se reconstrói lendo o código, e a terceira nem é sobre peso, é sobre o que a tela quer dizer quando não há peso.
- **Domínio enxuto.** Campo ou entity só existe quando algo do app realmente usa. Código especulativo é removido, não mantido "por garantia".

## Design system

Tokens em `lib/core/theme/`: `AppColors` (ThemeExtension, com par `x`/`xContainer` para badges), `AppSpacing`, `AppRadius`, `AppTextTheme`, `AppTheme`. Nunca use valor mágico de cor, espaçamento ou raio direto no widget — se falta um token, adicione o token.

O `ColorScheme` é escrito à mão (não `fromSeed`) por decisão deliberada — ver [ADR 0003](docs/adr/0003-design-system.md).

## Commits

Conventional Commits **inteiramente em inglês**, tipo e descrição (ex.: `refactor(shared): trim comments in Weight`). Título e descrição de PR também em inglês, e a descrição segue o formato da skill `/pr-description`. Commits antigos em português ficam como estão — não reescreva o histórico. Rode `git log --oneline -5` para conferir o tom antes de escrever.

Comentários de código e ADRs continuam em português.

Separe commits por assunto: correção de dívida técnica não vai junto com feature nova.

## Estado atual

O projeto segue um roadmap de sessões progressivas que vive no Notion (`myDesk → studies → projetos → FilamentOS → Roadmap`). Cada sessão traz teoria, exercícios e um checklist de aprovação.

**Fase 0 — Fundamentos: concluída.** Sessões 1 a 5 fechadas (setup, clean architecture, modelagem de domínio, design system, navegação). **Sessão 6 — Riverpod** é a próxima, e o item que ela existe para consertar já está descrito nas dívidas conhecidas.

O que existe hoje: domínio completo (`Filament`, `Print`, `Sale`, `Money`, `Weight`), o use case `RegisterPrint`, `FilamentsRepositoryFakeImpl` e `PrintsRepositoryFakeImpl` em memória, design system aplicado, navegação completa com `go_router` e 24 testes verdes.

Pendências da Sessão 5, na ordem em que o enunciado pede:

- ~~Texto de UI no `domain/`~~ — resolvido em duas etapas. Primeiro os quatro enums, que ficaram só com os valores enquanto os labels foram para extensions `*Label` na presentation. Depois `Money`, `Weight` e `Filament`, cujo `toString()` fazia a mesma coisa por outra porta: `stringify` do `Equatable` no lugar dos três, e `WeightLabel` em `shared/presentation/` para o único que a UI exibe.
- ~~`RegisterPrint` não persistia o `Print`~~ — resolvido. `PrintsRepositoryFakeImpl` implementado com exceções tipadas, e o use case grava o `Print` **antes** das baixas de estoque, por escolha registrada no próprio método.
- ~~`FilamentColor.toMaterial()` fora dos tokens~~ — decidido e mantido: cor de filamento é dado do produto, não decisão visual, então continua na paleta bruta do Material. O contraste vem de uma borda em `colorScheme.outline` no swatch. Justificativa registrada em `FilamentColorMaterial`.
- ~~`.gitkeep` em pastas populadas~~ — removidos de `features/`, `shared/` e, depois que o roteador nasceu, de `core/router/`. Só o de `core/config` segue válido, enquanto aquela pasta estiver vazia.
- ~~`lib/core/router/` vazia e navegação por `Navigator.push`~~ — resolvido. `go_router` configurado, `MaterialApp.router` no lugar do `home:`, e nenhuma feature importa a presentation de outra.

Navegação — o que já está de pé e o que falta:

- Feito: rotas de início, filamentos e impressões; rota de detalhe `/filaments/:id`; rota de erro (404) via `errorBuilder`; navegação por nome nas quatro rotas; `ShellRoute` com barra persistente; três testes de navegação.
- Feito também: `redirect` de guard com condição provisória. Falta só o opcional — ADR 0006 e o teste de deep link via `adb`.

**O guard é de rota, não de dado.** O app inteiro é privado (as informações são por usuário), inclusive o 404 — não vazar quais URLs existem para quem não está logado é deliberado. Duas regras, em níveis diferentes: no `GoRouter`, deslogado vai para `/login`; na rota de login, logado vai para a home. A regra geral mora no topo, e não na `ShellRoute`, porque só ali ela roda também para URLs que não casam com rota nenhuma. A exclusão do `/login` da regra geral é o que impede o loop — **e, medido, neste desenho o loop não é alcançável mesmo sem ela**, porque o `go_router` trata "redirecionar para onde você já está" como nada a fazer e o destino da regra é justamente a rota excluída; ela fica por tornar a intenção explícita. A condição é um parâmetro de `createRouter()`, nunca uma flag global, e na Sessão 7 deixa de ser `bool` e passa a vir do Firebase.

**A barra de navegação tem uma fonte só.** `NavBarOptions.all` (em `core/presentation/`) guarda ícone, rótulo, nome de rota e ordem juntos num Record; o `AppShell` deriva dela as `destinations`, a aba acesa e o destino do toque. Já foram duas listas paralelas alinhadas à mão — reordenar só uma quebrava a navegação com o `analyze` limpo. Guarda `IconData`, não `Icon`: dado, não widget.

**Convenções de rota.** `AppPaths` (caminhos) é lido só pelo `app_router.dart`; `AppRouteNames` (nomes de destino) é lido pelas telas. Telas navegam por nome, nunca por path — assim nenhuma delas conhece o formato da URL. Exceção deliberada: `FilamentsPage` importa `AppPaths` só por `idParam`, a chave de `pathParameters` ao navegar pro detalhe — é nome de parâmetro, não path, e o mesmo texto que aparece na declaração da rota. Fora esse único caso, nenhuma tela importa `AppPaths`. Rota filha usa path relativo (`:id`, sem barra). Telas de detalhe recebem **id**, nunca a entity: URL carrega texto, não objeto, e uma tela que depende da anterior lhe entregar o objeto quebra em deep link.

**Deep link está ligado no Android**, por esquema próprio: `filamentos://app/<path>`. Exige duas coisas no `AndroidManifest.xml`, e faltar qualquer uma falha em silêncio — um `intent-filter` de `VIEW` com `DEFAULT` e `BROWSABLE`, e o `meta-data flutter_deeplinking_enabled` **dentro da `<activity>`** (é o `FlutterActivity` que lê essa chave, do `ActivityInfo`; na `<application>` ela é ignorada sem erro). Testar: `adb shell am start -a android.intent.action.VIEW -d "filamentos://app/filaments/00001"` — o `adb` mora em `~/Library/Android/sdk/platform-tools/` e não está no PATH.

**Uma exceção deliberada:** o botão "Teste Not Found" da `HomePage` navega por path literal. `goNamed` com nome desconhecido lança assertion e derruba o app (nome inválido só pode vir do programador); só `go` com path inválido cai no `errorBuilder`. É andaime e sai quando o teste de navegação cobrir o 404.

**`ShellRoute` e os dois eixos.** As três áreas (início, filamentos, impressões) vivem dentro de um `ShellRoute` que mantém a `NavigationBar` viva enquanto só o miolo troca. A tela de detalhe fica **fora** do shell (sem barra) mas **continua filha** de `/filaments` na árvore de caminhos: aninhamento de path define a pilha e o botão de voltar; `parentNavigatorKey` define qual `Navigator` desenha a tela. São eixos independentes. As duas `GlobalKey` nascem **dentro** do `createRouter()`, nunca como campo estático — key estática seria compartilhada por todo roteador que a fábrica produzisse.

**A aba acesa é derivada, nunca guardada.** O `AppShell` lê `GoRouterState.of(context).topRoute?.name` a cada build e procura o `routeName` correspondente em `NavBarOptions.all`. Guardar o índice criaria segunda fonte de verdade, que desincroniza na primeira navegação que não venha da barra (botão da `HomePage`, deep link). Por isso o widget é `StatelessWidget`. Compara **nome com nome**, o que mantém `AppPaths` fora da presentation. Quando a rota não é nenhuma das abas, a busca devolve -1 e o fallback é a Home — a `NavigationBar` não aceita "nenhuma selecionada", então escolhe-se a mentira menos surpreendente, alinhada ao `initialLocation`.

**`AppRouter` expõe dois membros.** `router` é a instância única que o `MyApp` usa; `createRouter()` fabrica um `GoRouter` novo e é o que **todo teste de navegação deve chamar**. `static` é uma instância por isolate e o `flutter test` roda o arquivo num isolate só, então testes que compartilhem `AppRouter.router` herdam a posição de navegação uns dos outros. Não é a `factory` do Dart: aquela palavra-chave só devolve a própria classe, e aqui se fabrica um `GoRouter`.

## Dívidas conhecidas, adiadas de propósito

Não conserte estas por iniciativa própria — cada uma tem uma sessão dona.

- **Test double para a ordem das escritas do `RegisterPrint`** (Fase 1). A decisão de gravar o `Print` antes das baixas de estoque está protegida só por um comentário, e comentário não roda no CI: inverter as duas linhas mantém todos os testes verdes. Testar isso exige um `FilamentsRepository` que falhe de propósito no `update` — um dublê que simula falha, diferente do fake que simula sucesso. Um dado ruim não serve para provocar essa falha, porque as passadas 1 e 2 do `call()` filtram tudo antes da fase de escrita; só a infraestrutura pode falhar ali.
- **`WeightLabel` formata na mão, sem `NumberFormat` nem regra de plural.** A metade de *camada* desta dívida está paga: a formatação saiu do `toString()` de `Money`, `Weight` e `Filament` e virou uma extension na presentation. O que sobrou é a metade de *formatação*, e essa continua sendo da sessão de internacionalização: o separador decimal e a palavra `'gramas'` estão fixos em português, e `1000` miligramas imprime `1 gramas`. O teste que fixa esse plural errado **deve falhar** quando o `intl` entrar — é o lembrete, não um bug a consertar antes da hora.
- **Limiar de estoque baixo fixo em 100g** dentro de `StockStatus.fromWeight`. Deveria ser configurável por filamento ou por usuário.
- **Não há injeção de dependência: cada tela instancia o próprio repositório** (Sessão 6). Como o fake guarda os dados numa lista de instância, telas diferentes não compartilham dado nenhum — por isso a `FilamentDetailsPage` nunca acha o filamento, embora esteja correta. Tornar a lista `static` foi tentado e revertido: quebrou o isolamento entre testes, que passaram a herdar dados uns dos outros. O conserto é o `flutter_riverpod`.

Dependências declaradas no `pubspec.yaml` e ainda **sem uso**, cada uma reservada para uma sessão futura: `flutter_riverpod` (Sessão 6), `firebase_core`/`cloud_firestore` (Sessão 7), `hive`/`hive_flutter` (Sessão 8), `intl` (internacionalização). Não antecipe o uso delas — cada sessão tem escopo fechado de propósito. O `go_router` saiu desta lista: está em uso desde a Sessão 5.

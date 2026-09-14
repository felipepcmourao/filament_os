# Gerenciamento de Estado com Riverpod

## Contexto
Até a Sessão 5, cada tela instanciava o próprio repositório (`final filamentRepository = FilamentsRepositoryFakeImpl();` dentro do `State`). Como o fake guarda os dados numa lista de instância, telas diferentes nunca compartilhavam dado nenhum: a `FilamentDetailsPage` nunca achava um filamento que a `FilamentsPage` tinha acabado de adicionar, porque cada uma vivia com sua própria cópia do repositório. Uma tentativa de remendo — tornar a lista do fake `static` — foi revertida, porque estado global compartilhado quebrou o isolamento entre testes.

A Sessão 6 também trouxe dois problemas de reatividade que o app não tinha: o guard de rota (`redirect` do `GoRouter`) precisava reagir a uma troca de autenticação **sem reiniciar o app**, e a troca de tema precisava propagar de um controle na UI até o `MaterialApp.router` sem `setState` manual em cada tela.

## Decisão

### Riverpod herdado, não escolhido por comparação
Registrado por honestidade, no mesmo espírito da [ADR 0006](0006-navegacao.md) sobre o `go_router`: `flutter_riverpod` já estava no `pubspec.yaml`, reservado para esta sessão pelo roadmap do projeto. **Não houve comparação avaliada entre Riverpod, `package:provider`, BLoC ou `setState`.** A decisão de fato avaliada nesta sessão foi outra: injeção de dependência reativa, com um grafo de providers, *versus* o que já existia — cada tela instanciando e guardando sua própria dependência sem nenhum mecanismo de compartilhamento. Riverpod resolveu isso porque `ProviderScope` mantém uma única instância por `ProviderContainer`, acessível de qualquer widget descendente sem precisar passar a dependência de construtor em construtor.

### Providers escritos à mão, sem codegen
`riverpod_generator`, `riverpod_annotation` e `build_runner` não entraram no `pubspec.yaml`. Toda declaração usa a API manual (`Provider(...)`, `NotifierProvider(...)`, `AsyncNotifierProvider(...)`), sem `@riverpod` e sem arquivo `.g.dart`. Escolha consciente: nenhuma dependência nova, nenhum processo de build rodando em paralelo ao `flutter run`, e o provider inteiro visível num único arquivo — importante numa sessão de aprendizado, onde entender o que o Riverpod faz por baixo importa mais que a sintaxe mais compacta que o gerador ofereceria. Aplicado sem exceção: toda referência a construtor usa tear-off (`FilamentsListNotifier.new`, `AuthNotifier.new`, `ThemeModeNotifier.new`), nunca `() => Classe()`.

### Três formas de provider, cada uma para um papel
- **`Provider<T>`** para injeção pura ou valor derivado sem estado próprio: `filamentsRepositoryProvider`, `printsRepositoryProvider` e `registerPrintProvider` (que lê os outros dois), e `filamentByIdProvider` (`Provider.family`, deriva de `filamentsListProvider` filtrando por `id` com `.whenData`, sem buscar no repositório de novo).
- **`Notifier<T>`** para estado síncrono mutável com métodos: `authProvider` e `themeModeProvider`. Nenhum dos dois guarda nada assíncrono — é só um valor que a UI altera.
- **`AsyncNotifier<T>`** para estado que nasce de uma chamada assíncrona (o repositório) e ainda expõe métodos que mutam: só `filamentsListProvider`, cujo `build()` lista o repositório e cujos `addFilament`/`removeFilament` escrevem nele e recarregam o estado via `AsyncValue.guard`.

Deliberadamente fora: `StateNotifier`/`StateProvider`, legado no Riverpod 3.x. E `ChangeNotifierProvider` nunca aparece — o único `ChangeNotifier` do projeto (`GoRouterRefreshNotifier`) não é gerenciado pelo Riverpod como estado de app; existe só como adaptador de uma via, ligando `ref.listen(authProvider, ...)` ao `refreshListenable` que o `GoRouter` já exigia antes de qualquer Riverpod existir. Ferramenta do Flutter puro numa função estreita, não o padrão de estado do projeto.

### Onde os providers moram
Regra sem exceção, essa sim explícita no enunciado da sessão: **`domain/` nunca importa Riverpod.** `RegisterPrint` é um use case do domínio, mas o provider que o instancia (`registerPrintProvider`) não mora em `domain/`, porque é fora dele que a instanciação — e não a regra de negócio — acontece.

O critério é: **o provider mora onde a dependência que ele resolve nasce**, com uma quarta pasta reservada só pra injeção (ver revisão abaixo).
- **`di/`** (por feature) guarda os providers que ligam uma abstração à sua implementação concreta — `filamentsRepositoryProvider`, `printsRepositoryProvider` — e, por extensão, `registerPrintProvider`, que depende dos outros dois pra montar o use case.
- **`presentation/`** guarda os providers de estado que uma tela consome diretamente — `filamentsListProvider`, `filamentByIdProvider`. Não é a definição original de `presentation/` do CLAUDE.md (widgets, páginas, extensions), mas a mesma lógica de "pertence a quem consome" aplicada a mais um tipo de arquivo.
- **`core/<área>`** guarda os providers cross-cutting, um por área que já existia antes deles: `core/auth/authProvider`, `core/theme/themeModeProvider`, `core/router/routerProvider` (este ao lado do próprio `AppRouter`, que agora depende dele).

### Revisão: `di/` substitui `data/` como lar dos providers de injeção
Na primeira versão desta ADR, `filamentsRepositoryProvider`, `printsRepositoryProvider` e `registerPrintProvider` moravam em `data/`. Isso criava dois problemas ao mesmo tempo:

1. **Ambiguidade de papel.** `data/` é a camada de implementação concreta do repositório (`FilamentsRepositoryFakeImpl`); o provider que a expõe não é a implementação, é o fio que liga quem consome a ela. Morar no mesmo lugar confundia as duas coisas.
2. **Import de `presentation/` em `data/`.** `filaments_list_notifier.dart`, em `presentation/`, precisava importar `filamentsRepositoryProvider` de `data/` — violação literal da regra "nenhuma feature importa `data/` de fora dela mesma", sustentada só por uma leitura ("o que atravessa é a abstração, não a implementação") que um grep discordaria.

Criar `di/` como pasta irmã de `domain/`, `data/` e `presentation/` resolve as duas: o provider de injeção tem endereço próprio, e `presentation/` passa a importar `di/` — nunca `data/` — o que tira a exceção sem enfraquecer a regra. A feature continua auto-contida: `di/` não é compartilhada entre features, só reorganiza o que já vivia dentro de cada uma.

Escopo da mudança, explícito porque não é tudo que mexeu: **só os providers de injeção** (repositório, use case) foram pra `di/`. Os de estado de tela (`filamentsListProvider`, `filamentByIdProvider`) continuam em `presentation/`, e os cross-cutting (`authProvider`, `themeModeProvider`, `routerProvider`) continuam em `core/<área>`.

### Regra para `autoDispose`
A regra adotada: **`autoDispose` é para provider cujo argumento cresce sem limite ao longo de uma sessão de uso e cujo valor não precisa sobreviver a quem o pediu.** Provider "de infraestrutura" — repositório, serviço, autenticação, tema, roteador — nunca leva `autoDispose`, porque precisa viver pelo tempo de vida inteiro do app: é literalmente o requisito de "instância única" da sessão, e descartá-lo assim que o último `ref.watch` saísse da árvore quebraria essa garantia na próxima tela que precisasse dele. É por isso que `filamentsRepositoryProvider`, `printsRepositoryProvider`, `registerPrintProvider`, `authProvider`, `themeModeProvider`, `routerProvider` e `filamentsListProvider` não usam.

Provider "de tela", parametrizado por algo que o usuário navega, leva. `filamentByIdProvider` (`Provider.autoDispose.family<AsyncValue<Filament?>, String>`) é o único caso do projeto: cada `id` de filamento visitado criava uma entrada nova que nunca era liberada, mesmo depois de a `FilamentDetailsPage` correspondente sair da tela — `autoDispose` descarta essa entrada assim que nenhum widget mais observa aquele `id`.

### Granularidade de rebuild: `Consumer` isolado onde há `watch`
`FilamentsPage` é `StatelessWidget`, não `ConsumerWidget`, e só a parte da árvore que lê `filamentsListProvider` fica dentro de um `Consumer`. Com `ConsumerWidget`, o método `build` inteiro reconstrói a cada mudança do provider — inclusive `Scaffold` e `AppBar`, que não dependem de nenhum estado. Isolando o `ref.watch` num `Consumer` menor, só aquele trecho reconstrói.

A regra tem uma condição que a primeira versão desta seção não explicitava: **só `ref.watch` inscreve o widget no provider.** `ref.read` lê o valor uma vez, no momento da chamada, e não provoca rebuild nenhum. Isolar em `Consumer` só tem efeito onde existe `watch`. Revisitadas na Sessão 7, as outras três telas ficaram assim:

* **`FilamentDetailsPage`** virou `StatelessWidget`. A `AppBar` mostra o `id` recebido pelo construtor, que não muda, e só o `body` — que faz `watch` de `filamentByIdProvider(id)` — fica dentro do `Consumer`.
* **`PrintsPage`** virou `StatelessWidget` com **dois** `Consumer`, um por provider. Antes, os dois `watch` no topo do `build` faziam uma mudança na lista de filamentos reconstruir também a lista de impressões, e vice-versa. O botão de registrar continua atualizando as duas porque invalida os dois providers explicitamente, não porque compartilha o `build`. Detalhe de layout que o `analyze` não pega: o `Expanded` precisa ser filho direto da `Column`, então ele fica **por fora** do `Consumer`, sempre presente, e o `when` escolhe só o que vai dentro dele — com o `Consumer` entre os dois, o Flutter lança `Incorrect use of ParentDataWidget` em runtime.
* **`HomePage`** continua `ConsumerWidget` inteira, por decisão. Ela não tem nenhum `watch`: os três `ref.read(themeModeProvider.notifier)` estão dentro de `onPressed`, então a tela não reconstrói quando o tema muda e o `ConsumerWidget` não custa rebuild algum. Envolver só os três botões num `Consumer` também funcionaria, mas não ganharia nada em desempenho e acrescentaria um nível de aninhamento à tela; o `ref` do `build`, único e disponível para a tela toda, lê melhor.

## Consequências

### Positivas
* **O bug central da Sessão 5 desapareceu de graça:** um filamento adicionado na `FilamentsPage` aparece na `FilamentDetailsPage` porque as duas leem o mesmo `filamentsListProvider`, sem nenhuma mudança na lógica de busca da tela de detalhe além de trocar a fonte.
* **Reatividade sem `setState` manual espalhado:** trocar `authProvider` reflete no roteador, trocar `themeModeProvider` reflete no `MaterialApp.router`, ambos através de `ref.watch` — nenhuma tela precisa saber que outra mudou algo.
* **Teste substitui dependência real sem tocar em produção:** `ProviderContainer(overrides: [...])` trocou o repositório inteiro por um fake controlado (`FilamentRepositoryForTest1`/`2`) e o estado de autenticação (`LoggedOutNotifier`) em testes de widget, sem `mock` de framework nenhum.
* **A exceção "`presentation/` importa `data/`" deixou de existir.** Com `di/` no lugar, `filaments_list_notifier.dart` importa `filamentsRepositoryProvider` de `di/`, não de `data/` — a regra "nenhuma feature importa `data/` de fora dela mesma" volta a valer sem interpretação nenhuma.
* **`domain/` continua testável isoladamente:** nenhuma entity, value object ou use case sabe que o Riverpod existe — os testes de domínio já escritos nas sessões anteriores não mudaram uma linha.

### Negativas / Trade-offs
* **Mais uma pasta por feature.** `di/` é a quarta subpasta de `lib/features/<feature>/`, ao lado de `domain/`, `data/` e `presentation/` — mais um lugar pra saber de cor antes de perguntar "onde isso mora".
* **Padrão de rebuild isolado (`Consumer` em vez de `ConsumerWidget`) só está em uma tela.** Enquanto `HomePage`, `FilamentDetailsPage` e `PrintsPage` não forem revisitadas, o projeto tem dois estilos convivendo, e uma tela nova pode copiar o exemplo errado.
* **Sem codegen, todo provider carrega o tipo genérico completo escrito à mão** (`AsyncNotifierProvider<FilamentsListNotifier, List<Filament>>`, por exemplo) — mais verboso que o `@riverpod` geraria, e sujeito a erro de digitação que o gerador evitaria.
* **A ponte `GoRouterRefreshNotifier` é acoplamento direto com uma API do `go_router` anterior ao Riverpod:** funciona porque `refreshListenable` aceita qualquer `Listenable`, mas é a única parte do projeto onde `ChangeNotifier` e Riverpod convivem na mesma classe — se o `go_router` mudar essa API, é o primeiro lugar que quebra.

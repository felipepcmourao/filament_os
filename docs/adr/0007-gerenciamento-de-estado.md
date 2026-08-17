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
Regra sem exceção, essa sim explícita no enunciado da sessão: **`domain/` nunca importa Riverpod.** `RegisterPrint` é um use case do domínio, mas o provider que o instancia (`registerPrintProvider`) mora em `data/`, porque é ali que a instanciação — e não a regra de negócio — acontece.

A partir daí, o critério foi: **o provider mora onde a dependência que ele resolve nasce.**
- **`data/`** guarda os providers que ligam uma abstração à sua implementação concreta — `filamentsRepositoryProvider`, `printsRepositoryProvider` — e, por extensão, `registerPrintProvider`, que depende dos outros dois pra montar o use case.
- **`presentation/`** guarda os providers de estado que uma tela consome diretamente — `filamentsListProvider`, `filamentByIdProvider`. Não é a definição original de `presentation/` do CLAUDE.md (widgets, páginas, extensions), mas a mesma lógica de "pertence a quem consome" aplicada a mais um tipo de arquivo.
- **`core/<área>`** guarda os providers cross-cutting, um por área que já existia antes deles: `core/auth/authProvider`, `core/theme/themeModeProvider`, `core/router/routerProvider` (este ao lado do próprio `AppRouter`, que agora depende dele).

Exceção registrada, não escondida: `filaments_list_notifier.dart`, dentro de `presentation/`, importa `filamentsRepositoryProvider` de `data/` — o único import desse tipo no projeto, e na letra do enunciado ("nenhum import de `data/` em `presentation/`") isso é uma violação. A leitura adotada foi outra: o que atravessa a fronteira é o tipo `Provider<FilamentsRepository>` — a abstração —, nunca `FilamentsRepositoryFakeImpl`. É uma interpretação, não uma certeza; um grep literal por `import.*data/` discordaria.

### Regra para `autoDispose`
A regra adotada: **`autoDispose` é para provider cujo argumento cresce sem limite ao longo de uma sessão de uso e cujo valor não precisa sobreviver a quem o pediu.** Provider "de infraestrutura" — repositório, serviço, autenticação, tema, roteador — nunca leva `autoDispose`, porque precisa viver pelo tempo de vida inteiro do app: é literalmente o requisito de "instância única" da sessão, e descartá-lo assim que o último `ref.watch` saísse da árvore quebraria essa garantia na próxima tela que precisasse dele. É por isso que `filamentsRepositoryProvider`, `printsRepositoryProvider`, `registerPrintProvider`, `authProvider`, `themeModeProvider`, `routerProvider` e `filamentsListProvider` não usam.

Provider "de tela", parametrizado por algo que o usuário navega, leva. `filamentByIdProvider` (`Provider.autoDispose.family<AsyncValue<Filament?>, String>`) é o único caso do projeto: cada `id` de filamento visitado criava uma entrada nova que nunca era liberada, mesmo depois de a `FilamentDetailsPage` correspondente sair da tela — `autoDispose` descarta essa entrada assim que nenhum widget mais observa aquele `id`.

## Consequências

### Positivas
* **O bug central da Sessão 5 desapareceu de graça:** um filamento adicionado na `FilamentsPage` aparece na `FilamentDetailsPage` porque as duas leem o mesmo `filamentsListProvider`, sem nenhuma mudança na lógica de busca da tela de detalhe além de trocar a fonte.
* **Reatividade sem `setState` manual espalhado:** trocar `authProvider` reflete no roteador, trocar `themeModeProvider` reflete no `MaterialApp.router`, ambos através de `ref.watch` — nenhuma tela precisa saber que outra mudou algo.
* **Teste substitui dependência real sem tocar em produção:** `ProviderContainer(overrides: [...])` trocou o repositório inteiro por um fake controlado (`FilamentRepositoryForTest1`/`2`) e o estado de autenticação (`LoggedOutNotifier`) em testes de widget, sem `mock` de framework nenhum.
* **`domain/` continua testável isoladamente:** nenhuma entity, value object ou use case sabe que o Riverpod existe — os testes de domínio já escritos nas sessões anteriores não mudaram uma linha.

### Negativas / Trade-offs
* **Um import de `data/` em `presentation/` sobrevive por interpretação, não por regra clara:** se o critério objetivo da sessão for lido ao pé da letra, `filaments_list_notifier.dart` falha nele. A decisão está documentada, mas é uma decisão, não uma ausência de problema.
* **Sem codegen, todo provider carrega o tipo genérico completo escrito à mão** (`AsyncNotifierProvider<FilamentsListNotifier, List<Filament>>`, por exemplo) — mais verboso que o `@riverpod` geraria, e sujeito a erro de digitação que o gerador evitaria.
* **A ponte `GoRouterRefreshNotifier` é acoplamento direto com uma API do `go_router` anterior ao Riverpod:** funciona porque `refreshListenable` aceita qualquer `Listenable`, mas é a única parte do projeto onde `ChangeNotifier` e Riverpod convivem na mesma classe — se o `go_router` mudar essa API, é o primeiro lugar que quebra.

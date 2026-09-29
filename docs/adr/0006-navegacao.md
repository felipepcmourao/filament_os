# Navegação Declarativa e Desacoplamento por Rota

## Contexto
A navegação do app era uma linha dentro de um `onPressed`: a `HomePage` importava a `FilamentsPage` e a instanciava dentro de um `Navigator.push`. Funcionava, e carregava quatro problemas.

O primeiro é o mesmo que a [ADR 0002](0002-camadas-clean-architecture.md) já tinha resolvido em outra camada: **a presentation de uma feature conhecia a presentation de outra**. Isso cresce em O(n²) — com dez features que navegam entre si, cada uma precisa conhecer as outras nove — e contradizia a regra central da arquitetura.

Os outros três decorrem de não existir endereço: nada identifica de forma serializável onde o usuário está, o que inviabiliza deep link (uma notificação futura de "filamento X acabou" não teria para onde apontar); e proteger rotas exigiria repetir a checagem em cada `push`, em vez de um ponto único de interceptação.

## Decisão

### Navegação declarativa, com a rota como contrato
As rotas passam a ser declaradas num só lugar (`lib/core/router/`), e quem navega pede um **destino** em vez de empurrar uma tela. É a mesma forma da ADR 0002: entre quem chama e quem executa entra um contrato, e a implementação deixa de ser conhecida por quem usa. Ali o contrato era a interface do repositório; aqui é o nome da rota.

O roteador mora em `core/` porque é infraestrutura transversal — ele conhece todas as telas justamente para que as features não precisem se conhecer entre si.

Registrado por honestidade: o `go_router` veio dado pelo roadmap do projeto e já estava no `pubspec.yaml`. **Não houve comparação com `auto_route`, `Beamer` ou Navigator 2.0 na mão.** A decisão de fato avaliada foi declarativo *versus* imperativo; a escolha da biblioteca foi herdada.

### Caminhos e nomes em classes separadas, com públicos opostos
`AppPaths` guarda os caminhos de URL e é lido **só** pelo `app_router.dart`. `AppRouteNames` guarda os identificadores de destino e é lido **pelas telas**. Telas navegam por nome (`goNamed`), nunca por path.

O efeito é que nenhuma tela conhece o formato das URLs: mudar `/filaments/:id` para outra coisa é uma linha no roteador e zero widget tocado. Isso não é só intenção documentada — nenhuma tela importa `AppPaths` hoje, e o compilador confirma.

Os caminhos ficam todos em `core/`, e não cada um na sua feature, pelo mesmo motivo: uma feature que precisasse do path de outra teria que importá-la. De quebra, ver o espaço de URLs inteiro num arquivo só torna visível uma colisão de path que ficaria escondida se cada feature declarasse a sua.

### A barra de navegação tem uma fonte só, e a aba acesa é derivada
`NavBarOptions.all` guarda ícone, rótulo, nome de rota e ordem juntos num Record (`NavigationBarOption`), e o `AppShell` deriva dela as `destinations`, a aba acesa e o destino do toque. Já foram duas listas paralelas — nomes de rota no `AppRouteNames`, ícones e rótulos no `AppShell` — alinhadas à mão, sem nada no compilador verificando. Medido: naquele desenho, reordenar só uma delas deixava a suíte vermelha; com a lista única, reordenar mantém tudo verde, porque não há segunda lista para discordar. É o mesmo motivo que fez `FilamentUsage` virar um Record no domínio: valores que precisam andar juntos andam juntos. A lista guarda `IconData`, e não `Icon`, porque o primeiro é dado e o segundo é widget; o `Icon` nasce no `build` do `AppShell`, onde tamanho e cor são decididos.

A aba acesa é **derivada** da URL a cada build, nunca guardada num campo, e por isso o `AppShell` é `StatelessWidget`. Guardar um índice criaria uma segunda fonte de verdade, que desincronizaria na primeira navegação que não viesse da barra: um botão da `HomePage` ou um deep link direto em `/prints` mudariam a tela sem passar pelo `onDestinationSelected`, e a barra ficaria acesa na aba errada. É a mesma ideia do `StockStatus`, calculado a partir do peso em vez de viver no `Filament`.

Quando a rota atual não é nenhuma aba, a busca devolve -1, e a `NavigationBar` estoura uma assertion com índice fora da faixa — uma tela que quebra por causa da própria decoração é pior que uma aba acesa errada. O fallback é a Home, alinhado ao `initialLocation`: se o app assume a Home quando não há URL, a barra assume o mesmo quando não reconhece a URL. As duas saídas são mentira, porque a `NavigationBar` não aceita "nenhuma aba selecionada"; escolhe-se a menos surpreendente. O índice da Home é procurado na lista, não escrito à mão, para que reordenar `NavBarOptions.all` não mude em silêncio para onde o fallback aponta.

### Telas de detalhe recebem id, nunca a entity
Esta é a decisão com mais consequência. Uma tela de detalhe recebe o **identificador** e busca o dado no repositório; nunca recebe o objeto de domínio pronto da tela anterior.

O motivo é deep link: uma URL carrega texto, não objeto. Uma tela que só funciona quando a anterior lhe entrega a entidade funciona por dentro do app e quebra quando alcançada de fora — por notificação, por link, ou por restauração de estado depois de o sistema matar o app.

### Path e Navigator são eixos independentes
As três áreas paralelas (início, filamentos, impressões) vivem dentro de um `ShellRoute`, que mantém a barra de navegação viva enquanto só o conteúdo troca. A tela de detalhe fica **fora** do shell, sem a barra, mas **continua filha** de `/filaments` na árvore de caminhos.

As duas coisas convivem porque são eixos diferentes: o aninhamento de path define a pilha de navegação — e portanto o botão de voltar, sem código nenhum para isso — enquanto o `parentNavigatorKey` define qual `Navigator` desenha a tela. Confundir os dois leva a escolher entre a barra e o botão de voltar, quando não é preciso escolher.

### O app inteiro é privado, inclusive o 404
As informações do FilamentOS são por usuário, então nenhuma tela é pública. O guard fica no `redirect` do `GoRouter`, e não na `ShellRoute`, porque só no topo ele roda também para URLs que não casam com rota alguma — é o que mantém o 404 privado e evita revelar quais caminhos existem a quem não está autenticado.

Enquanto não há autenticação (Sessão 7), a condição é um **parâmetro da fábrica do roteador**, nunca uma flag global. Isso mantém a costura pronta sem estado compartilhado: um teste constrói um roteador deslogado sem afetar os outros, e na sessão de autenticação só o tipo da condição muda.

## Consequências

### Positivas
* **Desacoplamento verificável, não declarado:** nenhuma feature importa a presentation de outra, e nenhuma tela importa `AppPaths` — as duas regras quebram o build se violadas, em vez de dependerem de revisão humana.
* **Toda tela é alcançável de fora:** deep link, notificação e restauração de estado passam a ser possíveis porque cada estado de navegação tem endereço.
* **Ponto único para proteger rotas:** a regra de acesso existe num lugar só, em vez de espalhada por cada chamada de navegação.
* **Testabilidade:** um teste navega direto para uma tela profunda sem simular cliques, e o roteador pode ser fabricado por teste.
* **Flutter Web de graça:** o botão voltar do navegador funciona sem trabalho adicional.

### Negativas / Trade-offs
* **Mais verboso no caso simples:** onde havia uma linha, passa a haver uma entrada no arquivo de rotas mais uma chamada. Num app de duas telas sem autenticação, a troca não compensaria.
* **A tela de detalhe paga o preço do id:** uma busca a mais, um estado de carregamento onde o dado já estaria pronto, e a obrigação de tratar id inexistente. É o custo direto de funcionar por qualquer caminho de entrada.
* **Dependência de terceiros ditando estrutura:** o formato do arquivo de rotas, o comportamento de `redirect` e a semântica de `ShellRoute` são do `go_router`. Trocar de biblioteca depois reescreveria `core/router/` inteiro — e a escolha dela, como registrado acima, não foi avaliada.
* **Acoplamentos que o compilador não vê:** a ordem dos destinos da barra e o mapeamento índice → rota vivem juntos por convenção, não por tipo. Quem verifica é teste, não build.
* **O guard protege uma condição falsa** até a Sessão 7. A mecânica está exercitada, a regra de negócio não.

# Design System: Tema Manual e Isolamento de Cores de Domínio

## Contexto
Foi construído um sistema de tema em `lib/core/theme/` (`AppColors`, `AppSpacing`, `AppRadius`, `AppTextTheme`, `AppTheme`) para centralizar as decisões visuais do app e evitar valores mágicos espalhados pelos widgets. Duas decisões dentro desse sistema têm trade-offs que não são óbvios só lendo o código e merecem registro.

## Decisão

### ColorScheme manual em vez de `ColorScheme.fromSeed`
A primeira tentativa foi gerar a paleta a partir de uma cor semente (`#C94A0C`) usando `ColorScheme.fromSeed`. O resultado ficou com tons pastéis/dessaturados, que não combinavam com a identidade visual pretendida para o app — mais saturada, de alto contraste, com uma pegada "tecnológica". Por isso, os papéis `primary`, `secondary`, `error` e `surface` do `ColorScheme` foram definidos manualmente, com instâncias separadas para os brightnesses claro e escuro (`#FF6A1A`/`#E85A0F`). Os demais papéis do `ColorScheme` (`primaryContainer`, `tertiary`, `outline`, `surfaceContainer*` etc.) continuam derivados automaticamente, e só serão definidos manualmente quando algum componente concreto precisar deles.

O `fromSeed` resolve o contraste sozinho, mas devolve tons que ninguém escolheu: o laranja da marca sai do algoritmo diferente do que entrou. Aqui a identidade visual vem antes da conveniência, e o custo é assumir a responsabilidade pelo contraste, que nenhum algoritmo garante mais.

### Cores de domínio num `ThemeExtension`, em pares
O `ColorScheme` cobre papéis genéricos (`primary`, `error`, `surface`), mas não sabe o que é "estoque baixo" ou "impressão falhou". Essas cores moram em `AppColors`, um `ThemeExtension`, e não em `static const` lidos direto do widget: constante estática não sabe se o app está em tema claro ou escuro, e pelo tema o Flutter entrega a paleta certa sem nenhum `if` no widget.

Toda cor aparece em par, `x`/`xContainer` (conteúdo e fundo), na mesma convenção do Material (`primary`/`primaryContainer`). As duas nascem juntas porque a informação que importa está no **contraste entre elas**: um badge legível é um par calibrado, não duas cores escolhidas em momentos diferentes. Os pares invertem de papel entre os temas (no claro, fundo claro e conteúdo escuro; no escuro, o oposto) e não são as mesmas cores com brilho ajustado: são duas paletas escolhidas à mão, pela mesma decisão que rejeitou o `fromSeed`.

### Tipografia: duas fontes, papéis separados
**Space Grotesk** nos tamanhos grandes (`display`, `headline`, `title`) e **Inter** nos pequenos (`body`, `label`). A Space Grotesk é geométrica e tem personalidade nos cortes das letras: aparece em título e some em texto corrido. A Inter foi desenhada para tela em corpo pequeno, onde legibilidade importa mais que caráter. Usar uma só nos dois papéis sacrificaria um dos lados. Tamanhos e pesos são os do Material; só a família muda.

### Cores de domínio isoladas da camada de presentation
Enums de domínio como `FilamentColor` e `StockStatus` não têm nenhuma dependência do Flutter — carregam só os dados/labels necessários pras regras de negócio. A tradução desses enums para `Color` (valores concretos do Material) fica em extensions dedicadas na camada de presentation (`FilamentColorMaterial`, `StockStatusMaterial`), usando `switch` exaustivo sem `default`. Isso garante que, se um novo valor for adicionado ao enum sem que exista o mapeamento de cor correspondente, o projeto simplesmente não compila — o erro é pego em tempo de build, não em runtime.

### Cor como dado do produto vs. cor como decisão visual
As duas extensions de cor seguem regras opostas, de propósito. Em `StockStatusMaterial` a cor **é** decisão visual: estoque baixo não é amarelo no mundo físico, é amarelo porque o design system decidiu que alerta é amarelo, e essa decisão muda com o tema. Por isso ela lê os tokens de `AppColors` (o par `x`/`xContainer`) em vez de `Colors.amber`. Em `FilamentColorMaterial` é o contrário: a cor de um filamento é dado do produto, não muda com o tema, e por isso vem da paleta bruta do Material.

## Consequências

### Positivas
* **Identidade visual sob controle:** a paleta reflete exatamente o visual pretendido, sem depender de heurísticas de geração automática do Material 3.
* **Domínio limpo:** `FilamentColor`/`StockStatus` continuam testáveis e reutilizáveis sem nenhum import de Flutter, respeitando a regra de dependência entre camadas definida na ADR 0002.
* **Falha em tempo de compilação:** esquecer de mapear uma cor para um novo valor de enum vira erro de build, não bug silencioso em produção.

### Negativas / Trade-offs
* **Manutenção manual da paleta:** sem `fromSeed`, evoluir a paleta (ex: adicionar um novo papel do `ColorScheme`) exige decidir e testar cada tom manualmente, em vez de confiar na geração automática do Material 3.
* **Boilerplate por enum de domínio:** cada novo enum "visual" (cor, status etc.) exige sua própria extension com switch exaustivo — mais arquivos e mais disciplina do que simplesmente colocar a cor direto no enum.

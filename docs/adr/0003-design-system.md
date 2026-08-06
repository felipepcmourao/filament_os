# Design System: Tema Manual e Isolamento de Cores de Domínio

## Contexto
Foi construído um sistema de tema em `lib/core/theme/` (`AppColors`, `AppSpacing`, `AppRadius`, `AppTextTheme`, `AppTheme`) para centralizar as decisões visuais do app e evitar valores mágicos espalhados pelos widgets. Duas decisões dentro desse sistema têm trade-offs que não são óbvios só lendo o código e merecem registro.

## Decisão

### ColorScheme manual em vez de `ColorScheme.fromSeed`
A primeira tentativa foi gerar a paleta a partir de uma cor semente (`#C94A0C`) usando `ColorScheme.fromSeed`. O resultado ficou com tons pastéis/dessaturados, que não combinavam com a identidade visual pretendida para o app — mais saturada, de alto contraste, com uma pegada "tecnológica". Por isso, os papéis `primary`, `secondary`, `error` e `surface` do `ColorScheme` foram definidos manualmente, com instâncias separadas para os brightnesses claro e escuro (`#FF6A1A`/`#E85A0F`). Os demais papéis do `ColorScheme` (`primaryContainer`, `tertiary`, `outline`, `surfaceContainer*` etc.) continuam derivados automaticamente, e só serão definidos manualmente quando algum componente concreto precisar deles.

### Cores de domínio isoladas da camada de presentation
Enums de domínio como `FilamentColor` e `StockStatus` não têm nenhuma dependência do Flutter — carregam só os dados/labels necessários pras regras de negócio. A tradução desses enums para `Color` (valores concretos do Material) fica em extensions dedicadas na camada de presentation (`FilamentColorMaterial`, `StockStatusMaterial`), usando `switch` exaustivo sem `default`. Isso garante que, se um novo valor for adicionado ao enum sem que exista o mapeamento de cor correspondente, o projeto simplesmente não compila — o erro é pego em tempo de build, não em runtime.

## Consequências

### Positivas
* **Identidade visual sob controle:** a paleta reflete exatamente o visual pretendido, sem depender de heurísticas de geração automática do Material 3.
* **Domínio limpo:** `FilamentColor`/`StockStatus` continuam testáveis e reutilizáveis sem nenhum import de Flutter, respeitando a regra de dependência entre camadas definida na ADR 0002.
* **Falha em tempo de compilação:** esquecer de mapear uma cor para um novo valor de enum vira erro de build, não bug silencioso em produção.

### Negativas / Trade-offs
* **Manutenção manual da paleta:** sem `fromSeed`, evoluir a paleta (ex: adicionar um novo papel do `ColorScheme`) exige decidir e testar cada tom manualmente, em vez de confiar na geração automática do Material 3.
* **Boilerplate por enum de domínio:** cada novo enum "visual" (cor, status etc.) exige sua própria extension com switch exaustivo — mais arquivos e mais disciplina do que simplesmente colocar a cor direto no enum.

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

**Feature-first + Clean Architecture em vertical slice.** Cada feature em `lib/features/<feature>/` tem até três camadas:

- `domain/` — entities, value objects, enums, exceções e use cases. **Zero imports de Flutter ou de infraestrutura.**
- `data/` — implementações concretas dos repositórios.
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
- **Enums de domínio são só os valores.** Nada de campo `label`, e nunca sobrescreva `toString()` neles — o padrão do Dart já devolve `FilamentColor.blue`, que é o que serve em log e stack trace.
- **`domain/` não carrega string de exibição**, sem exceção — nem quando o texto não muda com o idioma (`'PLA'` também mora na presentation). Uma regra sem ressalva é mais fácil de seguir do que uma que exige decidir caso a caso.
- **Toda tradução enum → UI mora numa `extension` na `presentation`**, com `switch` exaustivo e **sem `default`**, para que um valor novo sem mapeamento quebre em tempo de compilação e não em runtime. Duas famílias: `*Label` (getter `label`, devolve o texto exibido) e `*Material` (devolve `Color`/tokens). Ver `FilamentColorLabel` e `StockStatusMaterial`.
- **Domínio enxuto.** Campo ou entity só existe quando algo do app realmente usa. Código especulativo é removido, não mantido "por garantia".

## Design system

Tokens em `lib/core/theme/`: `AppColors` (ThemeExtension, com par `x`/`xContainer` para badges), `AppSpacing`, `AppRadius`, `AppTextTheme`, `MyTheme`. Nunca use valor mágico de cor, espaçamento ou raio direto no widget — se falta um token, adicione o token.

O `ColorScheme` é escrito à mão (não `fromSeed`) por decisão deliberada — ver [ADR 0003](docs/adr/0003-design-system.md).

## Commits

Conventional Commits com **descrição em português** (o tipo — `feat`, `fix`, `refactor` — fica em inglês, é parte da spec). Rode `git log --oneline -5` para conferir o tom antes de escrever.

Separe commits por assunto: correção de dívida técnica não vai junto com feature nova.

## Estado atual

O projeto segue um roadmap de sessões progressivas que vive no Notion (`myDesk → studies → projetos → FilamentOS → Roadmap`). Cada sessão traz teoria, exercícios e um checklist de aprovação.

**Fase 0 — Fundamentos:** sessões 1 a 4 concluídas (setup, clean architecture, modelagem de domínio, design system). **Sessão 5 — Navegação em andamento**, começando pela dívida técnica antes da navegação em si.

O que existe hoje: domínio completo (`Filament`, `Print`, `Sale`, `Money`, `Weight`), o use case `RegisterPrint`, `FilamentRepositoryFakeImpl` em memória, design system aplicado e 13 testes verdes.

Pendências da Sessão 5, na ordem em que o enunciado pede:

- ~~Texto de UI no `domain/`~~ — resolvido. Os quatro enums ficaram só com os valores e os labels foram para extensions `*Label` na presentation.
- `PrintsRepository` não tem implementação, e `RegisterPrint` monta o `Print` mas nunca o persiste — o estoque é debitado para uma impressão que não existe. Inclui decidir o que fazer se a gravação do `Print` falhar depois da baixa de estoque já ter sido persistida.
- `FilamentColor.toMaterial()` usa a paleta bruta do Material, passando por fora dos tokens.
- `lib/core/router/` está vazia; a navegação é `Navigator.push` e a `HomePage` importa a `FilamentsPage` direto.
- `lib/features/.gitkeep` e `lib/shared/.gitkeep` continuam em pastas já populadas.

Fora do escopo da Sessão 5, mas conhecido: `Money.toString()` e `Weight.toString()` devolvem texto formatado para exibição (`'EUR 10,00'`, `'450 gramas'`) e a UI depende disso. É o mesmo problema que foi tirado dos enums, entrando por outra porta — o conserto passa por `NumberFormat` do `intl` e fica para a sessão de internacionalização.

Dependências declaradas no `pubspec.yaml` e ainda **sem uso**, cada uma reservada para uma sessão futura: `go_router` (Sessão 5), `flutter_riverpod` (Sessão 6), `firebase_core`/`cloud_firestore` (Sessão 7), `hive`/`hive_flutter` (Sessão 8), `intl` (internacionalização). Não antecipe o uso delas — cada sessão tem escopo fechado de propósito.

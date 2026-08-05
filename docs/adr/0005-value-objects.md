# Value Objects para Grandezas do Domínio (Money e Weight)

## Contexto
O domínio da aplicação trabalha com grandezas que têm regras próprias e não podem ser representadas com segurança por tipos primitivos: dinheiro (`Money`) e peso (`Weight`, usado para o estoque de filamento). Usar `double` diretamente para essas grandezas expõe o projeto a erro de arredondamento acumulado em somas/subtrações repetidas, além de permitir estados fisicamente inválidos, como um peso negativo.

## Decisão
`Money` e `Weight` foram modelados como value objects imutáveis em `lib/shared/domain/`. Internamente, guardam o valor como `int` na menor unidade (centavos para `Money`, miligramas para `Weight`) em vez de `double` na unidade "humana" (reais, gramas) — inteiros não acumulam erro de arredondamento ao longo de operações sucessivas.

A criação é sempre via `factory`, nunca por construtor público: um construtor privado (`Money._`/`Weight._`) só guarda o valor, e o `factory` valida as invariantes (ex: peso não pode ser negativo) antes de instanciar. Isso garante que uma instância inválida nunca existe — quem recebe um `Weight` não precisa validar de novo. Operadores (`+`, `-`, `>`, `<` etc.) sempre retornam uma instância nova através do próprio `factory`, então uma operação que resultaria num estado inválido (ex: subtrair mais peso do que existe em estoque) já lança o erro no lugar onde o problema acontece, sem precisar de checagem manual em cada chamada.

## Consequências

### Positivas
* **Impossível representar um estado inválido:** peso negativo ou moedas incompatíveis (ver `CurrencyMismatchException`) nunca chegam a existir como instância, então o resto do código não precisa validar de novo.
* **Sem erro de arredondamento:** aritmética em inteiros (centavos/miligramas) elimina o problema clássico de somar muitos `double` ao longo do tempo.
* **Conversões centralizadas:** o código que converte entre a unidade interna e a unidade "humana" (`toGrams`, `fromGrams` etc.) fica num único lugar, em vez de espalhado como `* 1000` ou `/ 100` pelo app.

### Negativas / Trade-offs
* **Mais boilerplate por grandeza:** cada novo value object exige factory, validação, operadores e conversões próprias, em vez de usar o tipo primitivo direto.
* **Exige disciplina:** o ganho de segurança só existe se todo o código continuar passando por essas classes — qualquer código que "vaze" pra `int`/`double` cru perde as garantias.

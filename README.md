# filament_os

Um app para ajudar na organização, manutenção e controle de impressões 3D e dos filamentos usados nelas — estoque, custo por impressão e vendas do que é produzido.

## Sobre o projeto

Quem imprime em 3D com regularidade acumula um problema chato: perde a noção de quanto filamento ainda tem, quanto cada peça realmente custou (material + tempo de máquina) e quanto vale vender o que foi produzido. O `filament_os` existe pra resolver isso de forma simples — registrar o estoque de filamentos, debitar automaticamente o que é usado em cada impressão, calcular o custo proporcional de cada peça e, a partir daí, apoiar decisões de venda.

## Contexto

Este é um projeto de estudo, construído ao longo de uma sequência de aulas progressivas (chamadas aqui de "Sessões"), onde a complexidade técnica e o volume de código aumentam aos poucos — cada sessão introduz um conceito novo (value objects, invariantes de domínio, injeção de dependência, gerenciamento de estado, etc.) e o aplica em cima do que já existe.

Por ser um projeto de estudo, ele não busca só "funcionar" — busca ser um exercício de arquitetura, testes e boas práticas de desenvolvimento de software aplicadas a um caso real, do tamanho de um app pequeno mas não trivial.

## O que tem de diferente

Comparado a um app típico de portfólio ou tutorial, o `filament_os` investe deliberadamente em coisas que projetos pequenos costumam pular:

- **Clean Architecture por feature** (`domain` / `data` / `presentation`), documentada em [ADRs](docs/adr/) que explicam o porquê de cada decisão estrutural, não só o quê.
- **Domínio com invariantes reais**: entities como `Filament` e `Print` usam `factory` + construtor privado pra garantir que, se um objeto existe em memória, ele é válido — inconsistência não é algo que se valida depois, é algo que não chega a existir.
- **Value objects** (`Money`, `Weight`) em vez de `double`/`int` soltos, pra evitar bugs de unidade e moeda misturadas silenciosamente.
- **Casos de uso explícitos** (ex: `RegisterPrint`) que orquestram regras já existentes no domínio, em vez de lógica de negócio espalhada pela camada de apresentação.
- **Domínio enxuto de propósito**: entities e campos só existem quando algo do app realmente os usa — código especulativo ("vai que precisa depois") é removido, não mantido "por garantia".

## Funcionalidades

- **Filamentos** — cadastro e controle de estoque (peso disponível, custo, cor, tipo, diâmetro).
- **Impressões** — registro de impressões, com baixa automática de estoque e cálculo de custo proporcional ao material usado.
- **Vendas** — acompanhamento do que é vendido a partir do que foi produzido.
- **Dashboard** — visão geral do estado atual (estoque, impressões, vendas).

## Tecnologias

- Flutter/Dart
- Riverpod (gerenciamento de estado e injeção de dependência)
- Firebase (autenticação, banco de dados)
- Hive (banco de dados noSQL local)
- intl (internacionalização)
- GoRouter (navegação)

## Uso de IA

Este projeto é desenvolvido com apoio de IA (Claude) como ferramenta de desenvolvimento assistido, não como autora do código de produção. O uso concreto é: explicação de conceitos e teoria por trás de cada decisão (arquitetura, invariantes, testes), revisão e avaliação do código já escrito, ajuda na redação de comentários e mensagens de commit, e formatação. Toda a lógica de negócio, estrutura de classes e decisões de design são escritas e decididas por mim — a IA guia com perguntas e revisões, mas não implementa a solução no meu lugar.
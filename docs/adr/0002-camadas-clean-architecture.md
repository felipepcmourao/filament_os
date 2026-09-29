# Camadas Clean Architecture

Foi adotada uma organização por features em formato `vertical slice`. Dentro de cada feature, o código é separado nas camadas `domain`, `data` e `presentation`.

## Decisão

A decisão foi tomada principalmente pelo desacoplamento entre regras de negócio, fontes de dados e interface. Isso torna as responsabilidades mais claras, facilita testes isolados e reduz o impacto de mudanças em detalhes de implementação, como APIs, banco de dados ou bibliotecas externas.

Essa estrutura também permite definir os casos de uso desde o início, sem depender de uma implementação concreta de persistência ou comunicação externa. 

Os use cases explicitam o comportamento esperado pela aplicação e concentram a orquestração das regras de negócio, tornando esse comportamento mais simples de testar de forma isolada. 

Como este é um projeto de estudo, eles também favorecem a prática de conceitos importantes, como abstrações, injeção de dependências e testes automatizados, além de ajudarem a compreender melhor os fluxos da aplicação e suas responsabilidades.

Além disso, uma organização previsível e consistente facilita a leitura e a manutenção do código, tanto por pessoas quanto por ferramentas de apoio ao desenvolvimento.

### Ordem das escritas no `RegisterPrint`
O `RegisterPrint` grava o `Print` **antes** das baixas de estoque, e a ordem não é acidental. As duas escritas não são atômicas (não há transação por trás delas), então uma pode falhar depois de a outra ter sido gravada. A escolha é sobre qual das duas inconsistências sobra:

- **`Print` gravado, baixas não:** o estoque fica alto demais, mas o `filamentUsage` do `Print` diz exatamente quais filamentos e quantos gramas, e dá para refazer a baixa a partir dele.
- **Baixas gravadas, `Print` não:** sumiu material do estoque e nada no app explica para onde foi. O nome, o tempo e o custo da impressão não estão em lugar nenhum, e não há como reconstruir.

O `Print` é o evento, o fato que aconteceu; o estoque é estado derivado dele. Grava-se o evento primeiro porque só ele reconstrói o outro lado.

O conserto de verdade é fazer as duas escritas numa única operação atômica (transação ou batch do Firestore, ou o equivalente no Hive). Enquanto os repositórios forem listas em memória, escolher a ordem é tudo o que dá para fazer.

## Consequências

A adoção dessa estrutura aumenta a quantidade inicial de arquivos, abstrações e configurações. Para funcionalidades pequenas, isso pode representar um custo adicional e até resultar em complexidade desnecessária.

Em contrapartida, à medida que o aplicativo cresce, a separação de responsabilidades tende a facilitar manutenção, evolução, testes e substituição de tecnologias.

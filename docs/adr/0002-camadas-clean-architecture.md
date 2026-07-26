# Camadas Clean Architecture

Foi adotada uma organização por features em formato `vertical slice`. Dentro de cada feature, o código é separado nas camadas `domain`, `data` e `presentation`.

## Decisão

A decisão foi tomada principalmente pelo desacoplamento entre regras de negócio, fontes de dados e interface. Isso torna as responsabilidades mais claras, facilita testes isolados e reduz o impacto de mudanças em detalhes de implementação, como APIs, banco de dados ou bibliotecas externas.

Essa estrutura também permite definir os casos de uso desde o início, sem depender de uma implementação concreta de persistência ou comunicação externa. 

Os use cases explicitam o comportamento esperado pela aplicação e concentram a orquestração das regras de negócio, tornando esse comportamento mais simples de testar de forma isolada. 

Como este é um projeto de estudo, eles também favorecem a prática de conceitos importantes, como abstrações, injeção de dependências e testes automatizados, além de ajudarem a compreender melhor os fluxos da aplicação e suas responsabilidades.

Além disso, uma organização previsível e consistente facilita a leitura e a manutenção do código, tanto por pessoas quanto por ferramentas de apoio ao desenvolvimento.

## Consequências

A adoção dessa estrutura aumenta a quantidade inicial de arquivos, abstrações e configurações. Para funcionalidades pequenas, isso pode representar um custo adicional e até resultar em complexidade desnecessária.

Em contrapartida, à medida que o aplicativo cresce, a separação de responsabilidades tende a facilitar manutenção, evolução, testes e substituição de tecnologias.

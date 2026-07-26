# Estrutura de Pastas: Feature-First

## Contexto
Este é um projeto desenvolvido no contexto de uma sequência de aulas progressivas, onde a complexidade técnica e o volume de código aumentam de forma incremental ao longo do tempo.

## Decisão
Tendo em vista o crescimento programado do projeto e a necessidade de mantê-lo organizado e limpo desde o princípio, foi definida a organização de pastas baseada em **Feature-First** (por domínios/funcionalidades).

Esta abordagem agrupa todos os arquivos relacionados a uma mesma funcionalidade (componentes, lógica, testes, serviços) em um único diretório dedicado. Essa prática é amplamente adotada no mercado atual por facilitar a escalabilidade.

## Consequências

### Positivas
* **Manutenibilidade:** Maior facilidade para encontrar, alterar ou remover arquivos de uma funcionalidade específica.
* **Escalabilidade e Equipes:** Prepara o projeto para o crescimento contínuo e facilita a futura divisão de tarefas entre múltiplos desenvolvedores.
* **Isolamento:** Reduz o acoplamento entre módulos distintos da aplicação.

### Negativas / Trade-offs
* **Código Compartilhado:** Exige disciplina para identificar corretamente o que é específico de uma feature e o que deve ir para uma pasta global de recursos compartilhados (`shared`/`common`), evitando duplicações desnecessárias.
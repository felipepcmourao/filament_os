# Repositório com Implementação Fake antes do Banco Real

## Contexto
O projeto já tem `hive`, `hive_flutter`, `firebase_core` e `cloud_firestore` como dependências no `pubspec.yaml`, mas nenhuma feature está de fato persistindo dados nesses bancos ainda. Em vez de esperar a integração com um banco real para começar a construir as features, foi criada uma implementação `FilamentsRepositoryFakeImpl` que guarda os dados numa lista em memória.

## Decisão
`FilamentsRepository` é uma interface abstrata (`list`, `add`, `update`, `remove`), definida na camada de domínio, sem nenhum conhecimento de como os dados são persistidos. A `FilamentsRepositoryFakeImpl`, na camada de data, implementa essa interface guardando tudo numa `List<Filament>` em memória — os dados somem quando o app fecha.

Essa fake também replica o comportamento de falha que um banco real teria: `update` lança `FilamentNotUpdatedException` se o `id` não for encontrado, e `remove` lança `FilamentNotRemovedException` se nada for removido, em vez de falhar silenciosamente. Isso permite que a camada de presentation e os casos de uso sejam construídos e testados desde já, contra a interface, sem depender de nenhuma configuração de banco, autenticação ou conexão de rede — basta trocar a implementação injetada quando o Hive ou o Firestore entrarem em cena.

## Consequências

### Positivas
* **Desenvolvimento desacoplado do banco:** UI, casos de uso e testes avançam sem exigir configuração de Hive/Firebase, autenticação ou ambiente de rede.
* **Testes rápidos e determinísticos:** por rodar em memória, os testes que usam a fake não dependem de I/O nem de estado externo.
* **Contrato validado cedo:** erros de design na interface `FilamentsRepository` (métodos que faltam, assinaturas erradas) aparecem antes mesmo de existir uma implementação real.

### Negativas / Trade-offs
* **Comportamento não é garantidamente idêntico ao banco real:** a fake replica os casos de erro conhecidos (não encontrado), mas não reproduz particularidades reais de Hive/Firestore, como latência, falhas de rede ou conflitos de concorrência — isso só vai aparecer quando a implementação real for escrita.
* **Dados não persistem entre execuções:** qualquer teste manual do app perde o estado a cada reinício, o que é aceitável agora mas precisa ser lembrado ao demonstrar o app.

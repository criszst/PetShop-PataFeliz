# Pata Feliz — modelagem e implementação de banco de dados

Projeto acadêmico - **Grupo 05**, desenvolvido na disciplina de Modelagem de Dados. A proposta organiza os dados de um pet shop que vende produtos, agenda e executa serviços, controla compras e estoque e registra obrigações e movimentos financeiros.


## Índice

- [Parte 1 — levantamento e primeiras decisões](#parte-1--levantamento-e-primeiras-decisões)
- [Parte 2 — modelo, implementação e apresentação](#parte-2--modelo-implementação-e-apresentação)
- [Visão geral da modelagem](#visão-geral-da-modelagem)
- [Regras de negócio resumidas](#regras-de-negócio-resumidas)
- [Como executar os scripts](#como-executar-os-scripts)
- [Escopo e pontos de consistência](#escopo-e-pontos-de-consistência)
- [Integrantes](#integrantes)

## Parte 1 — levantamento e primeiras decisões

| Material | Conteúdo |
| --- | --- |
| [DER da Parte 1](Parte_1/DER/) | Versão inicial do diagrama, preservada como registro da evolução do projeto. |
| [Diário de bordo 1](Parte_1/Diario%20de%20Bordo/Di%C3%A1rio%20de%20bordo%201.pdf) | Discussões e decisões da primeira etapa de modelagem. |
| [Diário de bordo 2](Parte_1/Diario%20de%20Bordo/Diario%20de%20bordo%202.pdf) | Continuação das decisões de estrutura de dados. |
| [Documento da Parte 1](Parte_1/Diario%20de%20Bordo/Banco%20de%20dados%20-%20Projeto%203.pdf) | Entrega inicial e contexto do problema. |


## Parte 2 — modelo, implementação e apresentação

| Material | Conteúdo |
| --- | --- |
| [Documento final — Grupo 05](Parte_2/Grupo_05.pdf) | Problema, objetivos, RF/RNF, regras de negócio, DER, dicionário, modelo lógico, normalização, fluxogramas, controle financeiro, consultas e apêndices SQL. |
| [Apresentação](Parte_2/Slide_Apresentacao.pptx) | Slides de síntese e roteiro de apresentação. |
| [DER da Parte 2](Parte_2/DER/der.png) | Imagem do diagrama final. |
| [Criação do banco](Parte_2/SQL/criar_database.sql) | Estrutura das tabelas e restrições. |
| [Inserção de dados](Parte_2/SQL/insercao_dados.sql) | Dados fictícios para demonstração. |
| [Consultas SQL](Parte_2/SQL/consultas.sql) | Consultas gerenciais e de auditoria. |


## Visão geral da modelagem

| Área | Entidades principais |
| --- | --- |
| Clientes e serviços | `TUTOR`, `PET`, `TUTELA`, `AGENDAMENTO`, `ATENDIMENTO`, `ITEM_ATENDIMENTO`, `SERVICO`, `FUNCIONARIO` |
| Pedidos e produtos | `PEDIDO`, `ITEM_PEDIDO`, `PRODUTO` |
| Fornecimento e estoque | `FORNECEDOR`, `PRODUTO_FORNECEDOR`, `COMPRA`, `ITEM_COMPRA`, `MOVIMENTACAO_ESTOQUE` |
| Financeiro | `CONTA_A_RECEBER`, `PAGAMENTO`, `TAXA_OPERADORA`, `MOVIMENTO_CAIXA`, `CONCILIACAO`, `DESPESA`, `CONTA_A_PAGAR`, `BAIXA_PAGAR` |

`ITEM_PEDIDO`, `ITEM_COMPRA`, `ITEM_ATENDIMENTO`, `TUTELA` e `PRODUTO_FORNECEDOR` representam vínculos que possuem dados próprios ou resolvem relações de muitos para muitos. O documento final apresenta o significado dos atributos e as chaves propostas.

## Regras de negócio resumidas

- Um tutor solicita agendamentos e realiza pedidos; um pet pode ter histórico de agendamentos e atendimentos.
- Um atendimento registra os serviços executados e o funcionário responsável; `ITEM_ATENDIMENTO` guarda o valor cobrado por serviço.
- Um pedido possui itens de produto; `ITEM_PEDIDO` guarda quantidade e preço unitário praticado.
- Um fornecedor participa de compras; `ITEM_COMPRA` guarda os produtos, quantidades e preços de aquisição. `PRODUTO_FORNECEDOR` descreve a oferta de cada fornecedor para cada produto.
- `CONTA_A_RECEBER` descreve valores previstos; `PAGAMENTO`, valores efetivamente recebidos. `CONTA_A_PAGAR` e `BAIXA_PAGAR` representam obrigações e pagamentos efetuados. `MOVIMENTO_CAIXA` registra entradas e saídas efetivas.
- As entradas, saídas e ajustes de produtos são históricos em `MOVIMENTACAO_ESTOQUE`.


## Integrantes

- Adrian Cristian dos Santos — RGM 47567210
- Murilo Neves Aguiar — RGM 47443855
- Nickyson Alves Pereira Poliacov — RGM 47765798
- Pedro Henrique Amaral Silva — RGM 47580488
- Renan Rodrigues dos Santos — RGM 47497521
- Richard Fernandes Glogovchan — RGM 47934077
- Thales Alexandre — RGM 47645474

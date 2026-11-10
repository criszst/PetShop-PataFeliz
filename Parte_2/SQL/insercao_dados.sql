/*
===============================================================================
PATA FELIZ - Sistema de Gestão
Script 02 - Inserção de dados de teste (DML)
SGBD: MySQL 8.0+
Dependência: 01_schema.sql já executado
Banco: pata_feliz
IMPORTANTE:
- Este script insere dados fictícios para testes.
- Execute-o uma única vez em uma base recém-criada ou vazia.
- Os IDs são explícitos para facilitar a leitura e a validação das consultas.
- Não execute 01_schema.sql novamente depois de inserir estes dados:
 esse script contém DROP DATABASE IF EXISTS e apagará os registros.
- Se precisar recomeçar, execute 01_schema.sql e depois este arquivo.
===============================================================================
*/
USE pata_feliz;
START TRANSACTION;
/* ---------------------------------------------------------------------------
 1. CADASTROS BÁSICOS
 --------------------------------------------------------------------------- */
INSERT INTO tutor (id_tutor, nome, email, telefone, cpf) VALUES
(1, 'Mariana Costa', 'mariana.costa@email.com', '11987654321', '12345678901'),
(2, 'Rafael Almeida', 'rafael.almeida@email.com', '11987654322', '23456789012'),
(3, 'Camila Santos', 'camila.santos@email.com', '11987654323', NULL),
(4, 'Bruno Oliveira', 'bruno.oliveira@email.com', '11987654324', '45678901234'),
(5, 'Fernanda Lima', 'fernanda.lima@email.com', '11987654325', NULL);
INSERT INTO pet (id_pet, nome, raca, sexo) VALUES
(1, 'Mel', 'Golden Retriever', 'F'),
(2, 'Thor', 'Labrador', 'M'),
(3, 'Nina', 'Shih Tzu', 'F'),
(4, 'Max', 'Vira-lata', 'M'),
(5, 'Luna', 'Poodle', 'F'),
(6, 'Bob', 'Bulldog Francês', 'M');
INSERT INTO tutela (id_tutor, id_pet) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6),
(2, 4); -- Exemplo de pet associado a mais de um tutor.
INSERT INTO funcionario (id_funcionario, nome, cpf, telefone, cargo) VALUES
(1, 'Ana Paula Ribeiro', '56789012345', '11990001111', 'Tosadora'),
(2, 'Carlos Mendes', '67890123456', '11990002222', 'Banhista'),
(3, 'Juliana Ferreira', '78901234567', '11990003333', 'Veterinaria'),
(4, 'Pedro Henrique Souza', '89012345678', '11990004444', 'Atendente');
INSERT INTO servico
(id_servico, nome, descricao, valor_base, duracao_estimada) VALUES
(1, 'Banho', 'Banho completo para pets', 65.00, 60),
(2, 'Tosa', 'Tosa higiênica e estética', 85.00, 90),
(3, 'Consulta', 'Consulta veterinária', 120.00, 45),
(4, 'Hidratação', 'Hidratação da pelagem', 45.00, 30),
(5, 'Corte de unhas', 'Corte e cuidado das unhas', 25.00, 15);
/* ---------------------------------------------------------------------------
 2. AGENDAMENTOS E ATENDIMENTOS
 --------------------------------------------------------------------------- */
INSERT INTO agendamento
(id_agendamento, data_hora_prevista, status, id_tutor, id_pet, id_servico) VALUES
(1, '2026-11-03 09:00:00', 'CONCLUIDO', 1, 1, 1),
(2, '2026-11-04 10:30:00', 'CONCLUIDO', 2, 3, 2),
(3, '2026-11-08 14:00:00', 'AGENDADO', 3, 4, 3),
(4, '2026-11-09 11:00:00', 'CANCELADO', 4, 5, 1),
(5, '2026-11-10 15:00:00', 'REAGENDADO', 5, 6, 4),
(6, '2026-11-05 13:00:00', 'AUSENTE', 1, 2, 5);
INSERT INTO atendimento
(id_atendimento, data_hora_inicio, data_hora_fim, descricao, status,
id_pet, id_funcionario, id_agendamento) VALUES
(1, '2026-11-03 09:05:00', '2026-11-03 10:00:00',
'Banho completo realizado; pelagem em boas condições.',
'CONCLUIDO', 1, 2, 1),
(2, '2026-11-04 10:35:00', '2026-11-04 12:00:00',
'Tosa realizada conforme solicitação do tutor.',
'CONCLUIDO', 3, 1, 2),
(3, '2026-11-06 16:00:00', '2026-11-06 16:40:00',
'Atendimento realizado sem agendamento prévio.',
'CONCLUIDO', 2, 3, NULL);
INSERT INTO item_atendimento
(id_item_atendimento, valor_cobrado, id_atendimento, id_servico) VALUES
(1, 65.00, 1, 1),
(2, 85.00, 2, 2),
(3, 120.00, 3, 3),
(4, 45.00, 1, 4);
/* ---------------------------------------------------------------------------
 3. PRODUTOS, ESTOQUE E FORNECEDORES
 --------------------------------------------------------------------------- */
INSERT INTO produto
(id_produto, nome, descricao, quantidade_estoque, preco_venda_atual) VALUES
(1, 'Shampoo Neutro 500ml', 'Shampoo para higiene de pets', 40, 32.90),
(2, 'Condicionador 500ml', 'Condicionador para pelagem', 25, 38.50),
(3, 'Ração Premium 10kg', 'Ração para cães adultos', 18, 189.90),
(4, 'Brinquedo Mordedor', 'Brinquedo resistente para cães', 30, 29.90),
(5, 'Escova Pet', 'Escova para cuidados com a pelagem', 15, 24.90),
(6, 'Petisco Natural', 'Petisco para cães', 50, 18.00);
INSERT INTO fornecedor
(id_fornecedor, nome, cnpj, telefone, email) VALUES
(1, 'Distribuidora Animal', '12345678000190', '1133334444', 'vendas@distribuidoraan.com.br'),
(2, 'Pet Produtos Brasil', '23456789000101', '1144445555', 'contato@petprodutos.com.br'),
(3, 'Mundo Pet Atacado', '34567890000112', '1155556666', 'comercial@mundopet.com.br');
INSERT INTO produto_fornecedor
(id_produto, id_fornecedor, preco_referencia, prazo_entrega, codigo_produto_fornecedor) VALUES
(1, 1, 19.50, 5, 'SHN-500'),
(2, 1, 23.00, 5, 'CON-500'),
(3, 2, 142.00, 7, 'RAC-PRE-10'),
(4, 3, 15.00, 4, 'BRQ-MOR'),
(5, 2, 12.50, 6, 'ESC-PET'),
(6, 3, 9.00, 4, 'PTC-NAT'),
(3, 3, 145.00, 8, 'RAC-PRE-10B');
INSERT INTO movimentacao_estoque
(id_movimentacao, data_hora, tipo, motivo, quantidade, id_produto) VALUES
(1, '2026-10-25 09:00:00', 'ENTRADA', 'Estoque inicial', 50, 1),
(2, '2026-10-25 09:10:00', 'ENTRADA', 'Estoque inicial', 30, 2),
(3, '2026-10-25 09:20:00', 'ENTRADA', 'Estoque inicial', 20, 3),
(4, '2026-11-02 14:00:00', 'SAIDA', 'Venda de produtos', 10, 1),
(5, '2026-11-03 10:00:00', 'AJUSTE_POSITIVO', 'Correção de inventário', 2, 4),
(6, '2026-11-04 15:00:00', 'AJUSTE_NEGATIVO', 'Avaria identificada', 1, 5),
(7, '2026-10-25 09:30:00', 'ENTRADA', 'Estoque inicial', 28, 4),
(8, '2026-10-25 09:40:00', 'ENTRADA', 'Estoque inicial', 16, 5),
(9, '2026-10-25 09:50:00', 'ENTRADA', 'Estoque inicial', 50, 6);
/* ---------------------------------------------------------------------------
 4. PEDIDOS E COMPRAS
 --------------------------------------------------------------------------- */
INSERT INTO pedido (id_pedido, data_pedido, status, id_tutor) VALUES
(1, '2026-11-01 10:15:00', 'CONFIRMADO', 1),
(2, '2026-11-02 11:20:00', 'CONFIRMADO', 2),
(3, '2026-11-03 15:30:00', 'CONFIRMADO', 1),
(4, '2026-11-05 09:45:00', 'ABERTO', 3),
(5, '2026-11-06 16:10:00', 'CANCELADO', 4);
INSERT INTO item_pedido
(id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 2, 32.90),
(1, 6, 3, 18.00),
(2, 3, 1, 189.90),
(2, 4, 2, 29.90),
(3, 2, 1, 38.50),
(3, 5, 1, 24.90),
(4, 6, 2, 18.00),
(5, 4, 1, 29.90);
INSERT INTO compra (id_compra, data_compra, status, id_fornecedor) VALUES
(1, '2026-10-25', 'RECEBIDA', 1),
(2, '2026-10-26', 'RECEBIDA', 2),
(3, '2026-11-06', 'ABERTA', 3);
INSERT INTO item_compra
(id_compra, id_produto, quantidade, preco_unitario_compra) VALUES
(1, 1, 50, 19.50),
(1, 2, 30, 23.00),
(2, 3, 20, 142.00),
(2, 5, 20, 12.50),
(3, 4, 40, 15.00),
(3, 6, 60, 9.00);
/* ---------------------------------------------------------------------------
 5. FINANCEIRO - RECEBIMENTOS
 --------------------------------------------------------------------------- */
INSERT INTO taxa_operadora
(id_taxa, forma_pagamento, percentual_taxa, taxa_fixa) VALUES
(1, 'Cartao de credito', 2.50, 0.50),
(2, 'Cartao de debito', 1.20, 0.30),
(3, 'Pix', 0.00, 0.00);
INSERT INTO conta_a_receber
(id_conta_receber, numero_parcela, valor_previsto, data_vencimento, status, id_pedido) VALUES
(1, 1, 119.80, '2026-11-01', 'RECEBIDO_TOTAL', 1),
(2, 1, 249.70, '2026-11-02', 'RECEBIDO_PARCIAL', 2),
(3, 1, 63.40, '2026-11-03', 'A_RECEBER', 3),
(4, 1, 36.00, '2026-11-10', 'A_RECEBER', 4);
INSERT INTO pagamento
(id_pagamento, data_pagamento, valor_recebido, metodo, status,
id_conta_receber, id_taxa) VALUES
(1, '2026-11-01', 119.80, 'Pix', 'CONFIRMADO', 1, 3),
(2, '2026-11-02', 150.00, 'Cartao de credito', 'CONFIRMADO', 2, 1),
(3, '2026-11-04', 50.00, 'Cartao de debito', 'CONFIRMADO', 2, 2);
/* ---------------------------------------------------------------------------
 6. FINANCEIRO - DESPESAS, CONTAS A PAGAR E BAIXAS
 --------------------------------------------------------------------------- */
INSERT INTO despesa
(id_despesa, descricao, valor_previsto, competencia) VALUES
(1, 'Aluguel do estabelecimento', 2500.00, '2026-11-01'),
(2, 'Conta de energia', 480.00, '2026-11-01'),
(3, 'Serviço de internet', 150.00, '2026-11-01');
INSERT INTO conta_a_pagar
(id_conta_pagar, data_emissao, data_vencimento, valor_original,
numero_parcela, status, id_compra, id_despesa) VALUES
(1, '2026-10-25', '2026-11-10', 1665.00, 1, 'PARCIAL', 1, NULL),
(2, '2026-10-26', '2026-11-12', 3090.00, 1, 'ABERTO', 2, NULL),
(3, '2026-11-01', '2026-11-05', 2500.00, 1, 'PARCIAL', NULL, 1),
(4, '2026-11-01', '2026-11-08', 480.00, 1, 'ABERTO', NULL, 2),
(5, '2026-11-01', '2026-11-15', 150.00, 1, 'ABERTO', NULL, 3);
INSERT INTO baixa_pagar
(id_baixa, data_baixa, valor_pago, metodo, id_conta_pagar) VALUES
(1, '2026-11-05', 500.00, 'Pix', 1),
(2, '2026-11-05', 1000.00, 'Transferencia', 3);
/* ---------------------------------------------------------------------------
 7. MOVIMENTO DE CAIXA E CONCILIAÇÃO
 --------------------------------------------------------------------------- */
INSERT INTO movimento_caixa
(id_movimento_caixa, data_movimento, tipo, valor_bruto, valor_liquido,
id_pagamento, id_baixa) VALUES
(1, '2026-11-01', 'ENTRADA', 119.80, 119.80, 1, NULL),
(2, '2026-11-02', 'ENTRADA', 150.00, 145.75, 2, NULL),
(3, '2026-11-04', 'ENTRADA', 50.00, 49.40, 3, NULL),
(4, '2026-11-05', 'SAIDA', 500.00, 500.00, NULL, 1),
(5, '2026-11-05', 'SAIDA', 1000.00, 1000.00, NULL, 2);
INSERT INTO conciliacao
(id_conciliacao, data_conciliacao, valor_esperado, valor_extrato, id_movimento_caixa) VALUES
(1, '2026-11-02', 119.80, 119.80, 1),
(2, '2026-11-03', 145.75, 145.75, 2),
(3, '2026-11-05', 49.40, 49.30, 3),
(4, '2026-11-06', 500.00, 500.00, 4);
COMMIT;
/* Conferência rápida: deve retornar a quantidade de registros por tabela. */
SELECT 'tutor' AS tabela, COUNT(*) AS total FROM tutor
UNION ALL SELECT 'pet', COUNT(*) FROM pet
UNION ALL SELECT 'tutela', COUNT(*) FROM tutela
UNION ALL SELECT 'funcionario', COUNT(*) FROM funcionario
UNION ALL SELECT 'servico', COUNT(*) FROM servico
UNION ALL SELECT 'agendamento', COUNT(*) FROM agendamento
UNION ALL SELECT 'atendimento', COUNT(*) FROM atendimento
UNION ALL SELECT 'item_atendimento', COUNT(*) FROM item_atendimento
UNION ALL SELECT 'produto', COUNT(*) FROM produto
UNION ALL SELECT 'movimentacao_estoque', COUNT(*) FROM movimentacao_estoque
UNION ALL SELECT 'fornecedor', COUNT(*) FROM fornecedor
UNION ALL SELECT 'produto_fornecedor', COUNT(*) FROM produto_fornecedor
UNION ALL SELECT 'pedido', COUNT(*) FROM pedido
UNION ALL SELECT 'item_pedido', COUNT(*) FROM item_pedido
UNION ALL SELECT 'compra', COUNT(*) FROM compra
UNION ALL SELECT 'item_compra', COUNT(*) FROM item_compra
UNION ALL SELECT 'taxa_operadora', COUNT(*) FROM taxa_operadora
UNION ALL SELECT 'conta_a_receber', COUNT(*) FROM conta_a_receber
UNION ALL SELECT 'pagamento', COUNT(*) FROM pagamento
UNION ALL SELECT 'despesa', COUNT(*) FROM despesa
UNION ALL SELECT 'conta_a_pagar', COUNT(*) FROM conta_a_pagar
UNION ALL SELECT 'baixa_pagar', COUNT(*) FROM baixa_pagar
UNION ALL SELECT 'movimento_caixa', COUNT(*) FROM movimento_caixa
UNION ALL SELECT 'conciliacao', COUNT(*) FROM conciliacao;

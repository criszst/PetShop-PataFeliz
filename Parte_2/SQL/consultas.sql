/*
 ===============================================================================
 PATA FELIZ - Sistema de Gestão
 Script 03 - Consultas gerenciais e de auditoria (DQL)
 SGBD: MySQL 8.0+
 Dependência: 01_schema.sql e 02_dados_teste.sql já executados
 Banco: pata_feliz
 As consultas são independentes. Execute uma por vez ou selecione o bloco
 desejado no MySQL Workbench.
 ===============================================================================
*/
USE pata_feliz;

/* ===========================================================================
 A. CADASTROS, TUTORES E PETS
 =========================================================================== */

/* 01. Listar todos os tutores. */
SELECT
    id_tutor,
    nome,
    email,
    telefone
FROM tutor
ORDER BY nome;

/* 02. Listar pets e seus tutores.
 Um pet pode aparecer mais de uma vez se possuir mais de um tutor em TUTELA. */
SELECT
    p.id_pet,
    p.nome AS pet,
    p.raca,
    p.sexo,
    t.id_tutor,
    t.nome AS tutor
FROM tutela tu
INNER JOIN tutor t ON t.id_tutor = tu.id_tutor
INNER JOIN pet p ON p.id_pet = tu.id_pet
ORDER BY p.nome, t.nome;

/* 03. Localizar pets que ainda não possuem vínculo em TUTELA. */
SELECT
    p.id_pet,
    p.nome,
    p.raca
FROM pet p
LEFT JOIN tutela tu ON tu.id_pet = p.id_pet
WHERE tu.id_pet IS NULL
ORDER BY p.nome;

/* ===========================================================================
 B. AGENDAMENTOS E ATENDIMENTOS
 =========================================================================== */

/* 04. Agenda com tutor, pet e serviço. */
SELECT
    a.id_agendamento,
    a.data_hora_prevista,
    a.status,
    t.nome AS tutor,
    p.nome AS pet,
    s.nome AS servico
FROM agendamento a
INNER JOIN tutor t ON t.id_tutor = a.id_tutor
INNER JOIN pet p ON p.id_pet = a.id_pet
INNER JOIN servico s ON s.id_servico = a.id_servico
ORDER BY a.data_hora_prevista;

/* 05. Histórico de atendimentos de cada pet. */
SELECT
    p.nome AS pet,
    at.id_atendimento,
    at.data_hora_inicio,
    at.data_hora_fim,
    at.status,
    f.nome AS funcionario,
    at.descricao
FROM atendimento at
INNER JOIN pet p ON p.id_pet = at.id_pet
INNER JOIN funcionario f ON f.id_funcionario = at.id_funcionario
ORDER BY p.nome, at.data_hora_inicio DESC;

/* 06. Serviços executados e valores cobrados por atendimento. */
SELECT
    at.id_atendimento,
    p.nome AS pet,
    s.nome AS servico,
    ia.valor_cobrado,
    f.nome AS funcionario,
    at.data_hora_inicio
FROM item_atendimento ia
INNER JOIN atendimento at ON at.id_atendimento = ia.id_atendimento
INNER JOIN pet p ON p.id_pet = at.id_pet
INNER JOIN servico s ON s.id_servico = ia.id_servico
INNER JOIN funcionario f ON f.id_funcionario = at.id_funcionario
ORDER BY at.data_hora_inicio DESC, at.id_atendimento;

/* 07. Quantidade de atendimentos concluídos por funcionário. */
SELECT
    f.id_funcionario,
    f.nome AS funcionario,
    COUNT(at.id_atendimento) AS total_atendimentos_concluidos
FROM funcionario f
LEFT JOIN atendimento at
    ON at.id_funcionario = f.id_funcionario
        AND at.status = 'CONCLUIDO'
GROUP BY f.id_funcionario, f.nome
ORDER BY total_atendimentos_concluidos DESC, f.nome;

/* ===========================================================================
 C. PRODUTOS, ESTOQUE E FORNECEDORES
 =========================================================================== */

/* 08. Consulta geral de produtos e estoque. */
SELECT
    id_produto,
    nome,
    quantidade_estoque,
    preco_venda_atual,
    quantidade_estoque * preco_venda_atual AS valor_estimado_estoque
FROM produto
ORDER BY quantidade_estoque ASC, nome;

/* 09. Produtos e seus fornecedores. */
SELECT
    p.nome AS produto,
    f.nome AS fornecedor,
    pf.preco_referencia,
    pf.prazo_entrega,
    pf.codigo_produto_fornecedor
FROM produto_fornecedor pf
INNER JOIN produto p ON p.id_produto = pf.id_produto
INNER JOIN fornecedor f ON f.id_fornecedor = pf.id_fornecedor
ORDER BY p.nome, f.nome;

/* 10. Histórico de movimentações de estoque por produto. */
SELECT
    p.nome AS produto,
    me.data_hora,
    me.tipo,
    me.quantidade,
    me.motivo
FROM movimentacao_estoque me
INNER JOIN produto p ON p.id_produto = me.id_produto
ORDER BY p.nome, me.data_hora DESC;

/* ===========================================================================
 D. PEDIDOS E COMPRAS
 =========================================================================== */

/* 11. Pedidos realizados por tutor, com seus itens.
 O subtotal é calculado: quantidade x preço unitário. */
SELECT
    pe.id_pedido,
    pe.data_pedido,
    pe.status,
    t.nome AS tutor,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal_item
FROM pedido pe
INNER JOIN tutor t ON t.id_tutor = pe.id_tutor
INNER JOIN item_pedido ip ON ip.id_pedido = pe.id_pedido
INNER JOIN produto p ON p.id_produto = ip.id_produto
ORDER BY pe.data_pedido DESC, pe.id_pedido, p.nome;

/* 12. Valor total dos itens de cada pedido.
 O resultado é calculado a partir dos itens, não de uma coluna total em PEDIDO. */
SELECT
    pe.id_pedido,
    pe.data_pedido,
    pe.status,
    t.nome AS tutor,
    COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) AS total_pedido
FROM pedido pe
INNER JOIN tutor t ON t.id_tutor = pe.id_tutor
LEFT JOIN item_pedido ip ON ip.id_pedido = pe.id_pedido
GROUP BY pe.id_pedido, pe.data_pedido, pe.status, t.nome
ORDER BY pe.data_pedido DESC;

/* 13. Produtos mais vendidos por quantidade.
 Considera apenas pedidos que não estejam cancelados. */
SELECT
    p.id_produto,
    p.nome AS produto,
    COALESCE(SUM(
        CASE
            WHEN pe.status <> 'CANCELADO'
                THEN ip.quantidade
                ELSE 0
        END
    ), 0) AS quantidade_vendida
FROM produto p
LEFT JOIN item_pedido ip ON ip.id_produto = p.id_produto
LEFT JOIN pedido pe ON pe.id_pedido = ip.id_pedido
GROUP BY p.id_produto, p.nome
ORDER BY quantidade_vendida DESC, p.nome;

/* 14. Compras realizadas por fornecedor e respectivos itens. */
SELECT
    c.id_compra,
    c.data_compra,
    c.status,
    f.nome AS fornecedor,
    p.nome AS produto,
    ic.quantidade,
    ic.preco_unitario_compra,
    (ic.quantidade * ic.preco_unitario_compra) AS subtotal_compra
FROM compra c
INNER JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
INNER JOIN item_compra ic ON ic.id_compra = c.id_compra
INNER JOIN produto p ON p.id_produto = ic.id_produto
ORDER BY c.data_compra DESC, c.id_compra;

/* ===========================================================================
 E. FINANCEIRO - CONTAS A RECEBER E PAGAMENTOS
 =========================================================================== */

/* 15. Contas a receber com tutor e pedido de origem. */
SELECT
    car.id_conta_receber,
    car.numero_parcela,
    car.valor_previsto,
    car.data_vencimento,
    car.status,
    pe.id_pedido,
    t.nome AS tutor
FROM conta_a_receber car
INNER JOIN pedido pe ON pe.id_pedido = car.id_pedido
INNER JOIN tutor t ON t.id_tutor = pe.id_tutor
ORDER BY car.data_vencimento;

/* 16. Total recebido por conta e saldo calculado.
 Considera apenas pagamentos CONFIRMADOS. */
SELECT
    car.id_conta_receber,
    car.valor_previsto,
    COALESCE(SUM(
        CASE
            WHEN pg.status = 'CONFIRMADO'
                THEN pg.valor_recebido
                ELSE 0
        END
    ), 0) AS total_recebido_confirmado,
    car.valor_previsto - COALESCE(SUM(
        CASE
            WHEN pg.status = 'CONFIRMADO'
                THEN pg.valor_recebido
                ELSE 0
        END
    ), 0) AS saldo_calculado
FROM conta_a_receber car
LEFT JOIN pagamento pg
    ON pg.id_conta_receber = car.id_conta_receber
GROUP BY car.id_conta_receber, car.valor_previsto
ORDER BY car.id_conta_receber;

/* 17. Pagamentos recebidos por período.
 Altere as datas do WHERE conforme o período desejado. */
SELECT
    pg.data_pagamento,
    pg.metodo,
    COUNT(*) AS quantidade_pagamentos,
    SUM(pg.valor_recebido) AS total_registrado
FROM pagamento pg
WHERE pg.status = 'CONFIRMADO'
    AND pg.data_pagamento BETWEEN '2026-11-01' AND '2026-11-30'
GROUP BY pg.data_pagamento, pg.metodo
ORDER BY pg.data_pagamento, pg.metodo;

/* ===========================================================================
 F. FINANCEIRO - CONTAS A PAGAR E DESPESAS
 =========================================================================== */

/* 18. Contas a pagar e sua origem (compra ou despesa). */
SELECT
    cap.id_conta_pagar,
    cap.data_emissao,
    cap.data_vencimento,
    cap.valor_original,
    cap.status,
    c.id_compra,
    d.descricao AS despesa
FROM conta_a_pagar cap
LEFT JOIN compra c ON c.id_compra = cap.id_compra
LEFT JOIN despesa d ON d.id_despesa = cap.id_despesa
ORDER BY cap.data_vencimento;

/* 19. Total baixado e saldo calculado por conta a pagar. */
SELECT
    cap.id_conta_pagar,
    cap.valor_original,
    COALESCE(SUM(bp.valor_pago), 0) AS total_baixado,
    cap.valor_original - COALESCE(SUM(bp.valor_pago), 0) AS saldo_calculado
FROM conta_a_pagar cap
LEFT JOIN baixa_pagar bp
    ON bp.id_conta_pagar = cap.id_conta_pagar
GROUP BY cap.id_conta_pagar, cap.valor_original
ORDER BY cap.id_conta_pagar;

/* ===========================================================================
 G. CAIXA E CONCILIAÇÃO
 =========================================================================== */

/* 20. Movimentações de caixa e sua origem. */
SELECT
    mc.id_movimento_caixa,
    mc.data_movimento,
    mc.tipo,
    mc.valor_bruto,
    mc.valor_liquido,
    mc.id_pagamento,
    mc.id_baixa
FROM movimento_caixa mc
ORDER BY mc.data_movimento, mc.id_movimento_caixa;

/* 21. Resultado das conciliações. */
SELECT
    c.id_conciliacao,
    c.data_conciliacao,
    mc.tipo AS tipo_movimento,
    c.valor_esperado,
    c.valor_extrato,
    c.diferenca,
    c.status_conciliacao
FROM conciliacao c
INNER JOIN movimento_caixa mc
    ON mc.id_movimento_caixa = c.id_movimento_caixa
ORDER BY c.data_conciliacao DESC;

/* 22. Somente conciliações divergentes. */
SELECT
    id_conciliacao,
    data_conciliacao,
    valor_esperado,
    valor_extrato,
    diferenca,
    status_conciliacao
FROM conciliacao
WHERE status_conciliacao = 'DIVERGENTE'
ORDER BY data_conciliacao DESC;

/* ===========================================================================
 H. CONSULTAS DE AUDITORIA E INTEGRIDADE OPERACIONAL
 =========================================================================== */

/* 23. Pedidos sem itens.
 A consulta identifica pedidos sem item; a RN05 exige tratamento adicional
 por trigger/procedure ou pela aplicação, conforme decisão do projeto. */
SELECT
    pe.id_pedido,
    pe.data_pedido,
    pe.status
FROM pedido pe
LEFT JOIN item_pedido ip ON ip.id_pedido = pe.id_pedido
WHERE ip.id_pedido IS NULL;

/* 24. Contas a receber sem pagamentos registrados. */
SELECT
    car.id_conta_receber,
    car.valor_previsto,
    car.data_vencimento,
    car.status
FROM conta_a_receber car
LEFT JOIN pagamento pg
    ON pg.id_conta_receber = car.id_conta_receber
WHERE pg.id_pagamento IS NULL;

/* 25. Contas a pagar sem baixas registradas. */
SELECT
    cap.id_conta_pagar,
    cap.valor_original,
    cap.data_vencimento,
    cap.status
FROM conta_a_pagar cap
LEFT JOIN baixa_pagar bp
    ON bp.id_conta_pagar = cap.id_conta_pagar
WHERE bp.id_baixa IS NULL;

/* 26. Movimentos de caixa ainda sem conciliação. */
SELECT
    mc.id_movimento_caixa,
    mc.data_movimento,
    mc.tipo,
    mc.valor_bruto,
    mc.valor_liquido
FROM movimento_caixa mc
LEFT JOIN conciliacao c
    ON c.id_movimento_caixa = mc.id_movimento_caixa
WHERE c.id_conciliacao IS NULL;

/* 27. Produtos com estoque zerado. */
SELECT
    id_produto,
    nome,
    quantidade_estoque
FROM produto
WHERE quantidade_estoque = 0
ORDER BY nome;

/* 28. Agendamentos que não foram concluídos.
 Útil para acompanhar cancelamentos, ausências e agendamentos futuros. */
SELECT
    a.id_agendamento,
    a.data_hora_prevista,
    a.status,
    t.nome AS tutor,
    p.nome AS pet,
    s.nome AS servico
FROM agendamento a
INNER JOIN tutor t ON t.id_tutor = a.id_tutor
INNER JOIN pet p ON p.id_pet = a.id_pet
INNER JOIN servico s ON s.id_servico = a.id_servico
WHERE a.status <> 'CONCLUIDO'
ORDER BY a.data_hora_prevista;

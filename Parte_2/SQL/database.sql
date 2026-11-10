/* =====================================================================
 PATA FELIZ - Sistema de Gestão
 Script 01 - Criação do banco e das tabelas (DDL)
 SGBD: MySQL 8.0+ (testado na 8.0.46) | Engine: InnoDB | utf8mb4
 Base de referência: DER_PataFeliz.pdf (nomenclatura TUTOR/PET/PEDIDO).
 Convenções:
 - tabelas e colunas em snake_case, nome da tabela = nome da entidade
 do DER em minúsculas (IdTutor -> id_tutor);
 - PK substituta AUTO_INCREMENT nas entidades fortes; PK composta nas
 entidades associativas (tutela, item_pedido, item_compra,
 produto_fornecedor);
 - valores monetários DECIMAL(12,2); percentuais DECIMAL(5,2);
 - status como ENUM (valores em MAIÚSCULAS, sem acento).
 Comentários marcados com [DECISÃO] indicam pontos em que o DER não
 define a regra e foi adotada a interpretação descrita.
 ===================================================================== */
DROP DATABASE IF EXISTS pata_feliz;
CREATE DATABASE pata_feliz
 CHARACTER SET utf8mb4
 COLLATE utf8mb4_unicode_ci;
USE pata_feliz;
/* ---------------------------------------------------------------------
 1. CADASTROS BÁSICOS
 --------------------------------------------------------------------- */
CREATE TABLE tutor (
 id_tutor INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(120) NULL,
 telefone VARCHAR(20) NOT NULL,
 cpf CHAR(11) NULL, -- só dígitos; opcional (LGPD: coleta mínima)
 PRIMARY KEY (id_tutor),
 UNIQUE KEY uq_tutor_email (email),
 UNIQUE KEY uq_tutor_cpf (cpf),
 CONSTRAINT ck_tutor_cpf CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB COMMENT='Responsável pelos pets (solicita serviços e realiza pedidos)';
CREATE TABLE pet (
 id_pet INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(80) NOT NULL,
 raca VARCHAR(60) NULL,
 sexo CHAR(1) NULL, -- M = macho, F = fêmea
 PRIMARY KEY (id_pet),
 CONSTRAINT ck_pet_sexo CHECK (sexo IS NULL OR sexo IN ('M','F'))
) ENGINE=InnoDB COMMENT='Animal cadastrado; vínculo com o tutor via TUTELA';
/* TUTELA: associação N:N entre TUTOR e PET (conforme o DER).
 [DECISÃO] Mantida como no DER. Conflita com a RN02 (animal pertence a um
 único cliente) - ver relatório final. */
CREATE TABLE tutela (
 id_tutor INT UNSIGNED NOT NULL,
 id_pet INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_tutor, id_pet),
 KEY ix_tutela_pet (id_pet),
 CONSTRAINT fk_tutela_tutor FOREIGN KEY (id_tutor) REFERENCES tutor (id_tutor)
 ON DELETE CASCADE,
 CONSTRAINT fk_tutela_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet)
 ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Entidade associativa TUTOR x PET';
CREATE TABLE funcionario (
 id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 cpf CHAR(11) NOT NULL,
 telefone VARCHAR(20) NULL,
 cargo VARCHAR(50) NOT NULL,
 PRIMARY KEY (id_funcionario),
 UNIQUE KEY uq_funcionario_cpf (cpf),
 CONSTRAINT ck_funcionario_cpf CHECK (cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB COMMENT='Colaborador que realiza atendimentos';
CREATE TABLE servico (
 id_servico INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(80) NOT NULL,
 descricao VARCHAR(255) NULL,
 valor_base DECIMAL(12,2) NOT NULL,
 duracao_estimada SMALLINT UNSIGNED NOT NULL, -- em minutos
 PRIMARY KEY (id_servico),
 UNIQUE KEY uq_servico_nome (nome),
 CONSTRAINT ck_servico_valor CHECK (valor_base >= 0),
 CONSTRAINT ck_servico_duracao CHECK (duracao_estimada > 0)
) ENGINE=InnoDB COMMENT='Serviço oferecido (banho, tosa, consulta...)';
/* ---------------------------------------------------------------------
 2. AGENDAMENTO E ATENDIMENTO
 --------------------------------------------------------------------- */
/* AGENDAMENTO: no DER, um agendamento tem 1 tutor (solicita), 1 pet
 (participa de) e 1 serviço (é marcado em).
 Status derivados do fluxograma: AGENDADO -> REAGENDADO / CANCELADO /
 AUSENTE / CONCLUIDO. */
CREATE TABLE agendamento (
 id_agendamento INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_hora_prevista DATETIME NOT NULL,
 status ENUM('AGENDADO','REAGENDADO','CANCELADO','AUSENTE','CONCLUIDO')
 NOT NULL DEFAULT 'AGENDADO',
 id_tutor INT UNSIGNED NOT NULL,
 id_pet INT UNSIGNED NOT NULL,
 id_servico INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_agendamento),
 KEY ix_agendamento_data (data_hora_prevista),
 KEY ix_agendamento_tutor (id_tutor),
 KEY ix_agendamento_pet (id_pet),
 KEY ix_agendamento_servico (id_servico),
 CONSTRAINT fk_agendamento_tutor FOREIGN KEY (id_tutor) REFERENCES tutor (id_tutor),
 CONSTRAINT fk_agendamento_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
 CONSTRAINT fk_agendamento_servico FOREIGN KEY (id_servico) REFERENCES servico (id_servico)
) ENGINE=InnoDB COMMENT='Reserva de data/hora para um serviço de um pet';
/* ATENDIMENTO: execução do serviço. RN10: associado a um pet; RN12: realizado
 por exatamente um funcionário.
 [DECISÃO] id_agendamento é opcional (atendimento sem agendamento) e UNIQUE
 (um agendamento origina no máximo um atendimento; cancelado/ausente = nenhum). */
CREATE TABLE atendimento (
 id_atendimento INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_hora_inicio DATETIME NOT NULL,
 data_hora_fim DATETIME NULL,
 descricao TEXT NULL,
 status ENUM('EM_ANDAMENTO','CONCLUIDO','CANCELADO')
 NOT NULL DEFAULT 'EM_ANDAMENTO',
 id_pet INT UNSIGNED NOT NULL,
 id_funcionario INT UNSIGNED NOT NULL,
 id_agendamento INT UNSIGNED NULL,
 PRIMARY KEY (id_atendimento),
 UNIQUE KEY uq_atendimento_agendamento (id_agendamento),
 KEY ix_atendimento_pet (id_pet, data_hora_inicio),
 KEY ix_atendimento_funcionario (id_funcionario),
 CONSTRAINT fk_atendimento_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
 CONSTRAINT fk_atendimento_funcionario FOREIGN KEY (id_funcionario)
 REFERENCES funcionario (id_funcionario),
 CONSTRAINT fk_atendimento_agendamento FOREIGN KEY (id_agendamento)
 REFERENCES agendamento (id_agendamento),
 CONSTRAINT ck_atendimento_periodo
 CHECK (data_hora_fim IS NULL OR data_hora_fim >= data_hora_inicio)
) ENGINE=InnoDB COMMENT='Execução de serviço(s) para um pet';
/* ITEM_ATENDIMENTO: PK substituta, como no DER (IdItemAtendimento). */
CREATE TABLE item_atendimento (
 id_item_atendimento INT UNSIGNED NOT NULL AUTO_INCREMENT,
 valor_cobrado DECIMAL(12,2) NOT NULL,
 id_atendimento INT UNSIGNED NOT NULL,
 id_servico INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_item_atendimento),
 KEY ix_item_atendimento_atendimento (id_atendimento),
 KEY ix_item_atendimento_servico (id_servico),
 CONSTRAINT fk_item_atendimento_atendimento FOREIGN KEY (id_atendimento)
 REFERENCES atendimento (id_atendimento) ON DELETE CASCADE,
 CONSTRAINT fk_item_atendimento_servico FOREIGN KEY (id_servico)
 REFERENCES servico (id_servico),
 CONSTRAINT ck_item_atendimento_valor CHECK (valor_cobrado >= 0)
) ENGINE=InnoDB COMMENT='Serviço individual dentro de um atendimento';
/* ---------------------------------------------------------------------
 3. PRODUTOS, ESTOQUE E FORNECEDORES
 --------------------------------------------------------------------- */
CREATE TABLE produto (
 id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 descricao VARCHAR(255) NULL,
 quantidade_estoque INT NOT NULL DEFAULT 0,
 preco_venda_atual DECIMAL(12,2) NOT NULL,
 PRIMARY KEY (id_produto),
 KEY ix_produto_nome (nome),
 CONSTRAINT ck_produto_estoque CHECK (quantidade_estoque >= 0),
 CONSTRAINT ck_produto_preco CHECK (preco_venda_atual >= 0)
) ENGINE=InnoDB COMMENT='Mercadoria vendida e controlada em estoque';
/* [DECISÃO] quantidade > 0 e o sentido vem de tipo:
 ENTRADA / AJUSTE_POSITIVO somam; SAIDA / AJUSTE_NEGATIVO subtraem. */
CREATE TABLE movimentacao_estoque (
 id_movimentacao INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 tipo ENUM('ENTRADA','SAIDA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO') NOT NULL,
 motivo VARCHAR(150) NULL,
 quantidade INT NOT NULL,
 id_produto INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_movimentacao),
 KEY ix_movest_produto (id_produto, data_hora),
 CONSTRAINT fk_movest_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
 CONSTRAINT ck_movest_quantidade CHECK (quantidade > 0)
) ENGINE=InnoDB COMMENT='Histórico de entradas, saídas e ajustes de estoque';
CREATE TABLE fornecedor (
 id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 cnpj CHAR(14) NOT NULL,
 telefone VARCHAR(20) NULL,
 email VARCHAR(120) NULL,
 PRIMARY KEY (id_fornecedor),
 UNIQUE KEY uq_fornecedor_cnpj (cnpj),
 CONSTRAINT ck_fornecedor_cnpj CHECK (cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB COMMENT='Empresa que fornece produtos (RN07/RN08)';
/* PRODUTO_FORNECEDOR: N:N entre PRODUTO e FORNECEDOR (RN07/RN08). */
CREATE TABLE produto_fornecedor (
 id_produto INT UNSIGNED NOT NULL,
 id_fornecedor INT UNSIGNED NOT NULL,
 preco_referencia DECIMAL(12,2) NOT NULL,
 prazo_entrega SMALLINT UNSIGNED NULL, -- em dias
 codigo_produto_fornecedor VARCHAR(50) NULL,
 PRIMARY KEY (id_produto, id_fornecedor),
 KEY ix_prodforn_fornecedor (id_fornecedor),
 CONSTRAINT fk_prodforn_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
 ON DELETE CASCADE,
 CONSTRAINT fk_prodforn_fornecedor FOREIGN KEY (id_fornecedor)
 REFERENCES fornecedor (id_fornecedor) ON DELETE CASCADE,
 CONSTRAINT ck_prodforn_preco CHECK (preco_referencia >= 0)
) ENGINE=InnoDB COMMENT='Entidade associativa PRODUTO x FORNECEDOR';
/* ---------------------------------------------------------------------
 4. VENDAS (PEDIDO) E COMPRAS DE FORNECEDOR (COMPRA)
 --------------------------------------------------------------------- */
CREATE TABLE pedido (
 id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 status ENUM('ABERTO','CONFIRMADO','CANCELADO') NOT NULL DEFAULT 'ABERTO',
 id_tutor INT UNSIGNED NOT NULL, -- RN04
 PRIMARY KEY (id_pedido),
 KEY ix_pedido_tutor (id_tutor, data_pedido),
 KEY ix_pedido_data (data_pedido),
 CONSTRAINT fk_pedido_tutor FOREIGN KEY (id_tutor) REFERENCES tutor (id_tutor)
) ENGINE=InnoDB COMMENT='Venda de produtos a um tutor (RN03/RN04)';
/* ITEM_PEDIDO: PK composta (id_pedido, id_produto): o mesmo produto não se
 repete no pedido (mudar a quantidade). RN05 (pedido com >= 1 item) não é
 imposta por DDL: ver trigger/procedimento no script de regras. */
CREATE TABLE item_pedido (
 id_pedido INT UNSIGNED NOT NULL,
 id_produto INT UNSIGNED NOT NULL,
 quantidade INT NOT NULL,
 preco_unitario DECIMAL(12,2) NOT NULL, -- preço praticado no momento da venda
 PRIMARY KEY (id_pedido, id_produto),
 KEY ix_item_pedido_produto (id_produto),
 CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido)
 ON DELETE CASCADE,
 CONSTRAINT fk_item_pedido_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
 CONSTRAINT ck_item_pedido_qtd CHECK (quantidade > 0),
 CONSTRAINT ck_item_pedido_preco CHECK (preco_unitario >= 0)
) ENGINE=InnoDB COMMENT='Entidade associativa PEDIDO x PRODUTO (subtotal = quantidade * preco_unitario)';
CREATE TABLE compra (
 id_compra INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_compra DATE NOT NULL,
 status ENUM('ABERTA','RECEBIDA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
 id_fornecedor INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_compra),
 KEY ix_compra_fornecedor (id_fornecedor, data_compra),
 CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
 REFERENCES fornecedor (id_fornecedor)
) ENGINE=InnoDB COMMENT='Aquisição de mercadorias junto a um fornecedor';
CREATE TABLE item_compra (
 id_compra INT UNSIGNED NOT NULL,
 id_produto INT UNSIGNED NOT NULL,
 quantidade INT NOT NULL,
 preco_unitario_compra DECIMAL(12,2) NOT NULL,
 PRIMARY KEY (id_compra, id_produto),
 KEY ix_item_compra_produto (id_produto),
 CONSTRAINT fk_item_compra_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
 ON DELETE CASCADE,
 CONSTRAINT fk_item_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
 CONSTRAINT ck_item_compra_qtd CHECK (quantidade > 0),
 CONSTRAINT ck_item_compra_preco CHECK (preco_unitario_compra >= 0)
) ENGINE=InnoDB COMMENT='Entidade associativa COMPRA x PRODUTO';
/* ---------------------------------------------------------------------
 5. FINANCEIRO - RECEBIMENTOS
 (tabelas do script original, corrigidas e padronizadas)
 --------------------------------------------------------------------- */
CREATE TABLE taxa_operadora (
 id_taxa INT UNSIGNED NOT NULL AUTO_INCREMENT,
 forma_pagamento VARCHAR(50) NOT NULL, -- ex.: 'Visa Crédito', 'Pix'
 percentual_taxa DECIMAL(5,2) NOT NULL DEFAULT 0.00,
 taxa_fixa DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 PRIMARY KEY (id_taxa),
 UNIQUE KEY uq_taxa_forma (forma_pagamento),
 CONSTRAINT ck_taxa_percentual CHECK (percentual_taxa BETWEEN 0 AND 100),
 CONSTRAINT ck_taxa_fixa CHECK (taxa_fixa >= 0)
) ENGINE=InnoDB COMMENT='Taxas cobradas por meio de pagamento';
/* CONTA_A_RECEBER: FK para PEDIDO adicionada (DER e modelo lógico).
 Uma conta por parcela do pedido. */
CREATE TABLE conta_a_receber (
 id_conta_receber INT UNSIGNED NOT NULL AUTO_INCREMENT,
 numero_parcela TINYINT UNSIGNED NOT NULL DEFAULT 1,
 valor_previsto DECIMAL(12,2) NOT NULL,
 data_vencimento DATE NOT NULL,
 status ENUM('A_RECEBER','RECEBIDO_PARCIAL','RECEBIDO_TOTAL','EM_ATRASO')
 NOT NULL DEFAULT 'A_RECEBER',
 id_pedido INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_conta_receber),
 UNIQUE KEY uq_conta_receber_parcela (id_pedido, numero_parcela),
 KEY ix_conta_receber_vencimento (data_vencimento, status),
 CONSTRAINT fk_conta_receber_pedido FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
 CONSTRAINT ck_conta_receber_parcela CHECK (numero_parcela >= 1),
 CONSTRAINT ck_conta_receber_valor CHECK (valor_previsto > 0)
) ENGINE=InnoDB COMMENT='Direito de receber (uma linha por parcela)';
/* PAGAMENTO: várias linhas por conta = recebimentos parciais permitidos.
 id_taxa foi acrescentada (DER: PAGAMENTO utiliza TAXA_OPERADORA); é
 opcional porque dinheiro/Pix podem não ter taxa. */
CREATE TABLE pagamento (
 id_pagamento INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_pagamento DATE NOT NULL,
 valor_recebido DECIMAL(12,2) NOT NULL,
 metodo VARCHAR(50) NOT NULL,
 status ENUM('PENDENTE','CONFIRMADO','ESTORNADO') NOT NULL DEFAULT 'PENDENTE',
 id_conta_receber INT UNSIGNED NOT NULL,
 id_taxa INT UNSIGNED NULL,
 PRIMARY KEY (id_pagamento),
 KEY ix_pagamento_conta (id_conta_receber),
 KEY ix_pagamento_taxa (id_taxa),
 KEY ix_pagamento_data (data_pagamento),
 CONSTRAINT fk_pagamento_conta FOREIGN KEY (id_conta_receber)
 REFERENCES conta_a_receber (id_conta_receber),
 CONSTRAINT fk_pagamento_taxa FOREIGN KEY (id_taxa) REFERENCES taxa_operadora (id_taxa),
 CONSTRAINT ck_pagamento_valor CHECK (valor_recebido > 0)
) ENGINE=InnoDB COMMENT='Recebimento efetivo de uma conta a receber';
/* ---------------------------------------------------------------------
 6. FINANCEIRO - PAGAMENTOS A FORNECEDORES E DESPESAS
 --------------------------------------------------------------------- */
CREATE TABLE despesa (
 id_despesa INT UNSIGNED NOT NULL AUTO_INCREMENT,
 descricao VARCHAR(150) NOT NULL,
 valor_previsto DECIMAL(12,2) NOT NULL,
 competencia DATE NOT NULL, -- 1º dia do mês de competência
 PRIMARY KEY (id_despesa),
 CONSTRAINT ck_despesa_valor CHECK (valor_previsto >= 0)
) ENGINE=InnoDB COMMENT='Gasto operacional (aluguel, energia, salários...)';
/* CONTA_A_PAGAR: PK corrigida (o script original escrevia IdcontasPagar).
 [DECISÃO] Origem exclusiva: compra OU despesa (DER liga a ambas; o
 documento pede para permitir despesas sem COMPRA). Direção da FK com
 DESPESA segue o DER (cada conta a pagar aponta para 1 despesa). */
CREATE TABLE conta_a_pagar (
 id_conta_pagar INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_emissao DATE NOT NULL,
 data_vencimento DATE NOT NULL,
 valor_original DECIMAL(12,2) NOT NULL,
 numero_parcela TINYINT UNSIGNED NOT NULL DEFAULT 1,
 status ENUM('ABERTO','PARCIAL','PAGO','ATRASADO') NOT NULL DEFAULT 'ABERTO',
 id_compra INT UNSIGNED NULL,
 id_despesa INT UNSIGNED NULL,
 PRIMARY KEY (id_conta_pagar),
 KEY ix_conta_pagar_vencimento (data_vencimento, status),
 KEY ix_conta_pagar_compra (id_compra),
 KEY ix_conta_pagar_despesa (id_despesa),
 CONSTRAINT fk_conta_pagar_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
 CONSTRAINT fk_conta_pagar_despesa FOREIGN KEY (id_despesa) REFERENCES despesa (id_despesa),
 CONSTRAINT ck_conta_pagar_origem CHECK ((id_compra IS NULL) <> (id_despesa IS NULL)),
 CONSTRAINT ck_conta_pagar_valor CHECK (valor_original > 0),
 CONSTRAINT ck_conta_pagar_parcela CHECK (numero_parcela >= 1),
 CONSTRAINT ck_conta_pagar_datas CHECK (data_vencimento >= data_emissao)
) ENGINE=InnoDB COMMENT='Obrigação de pagar (uma linha por parcela)';
/* BAIXA_PAGAR: várias baixas por conta = pagamentos parciais permitidos.
 FK corrigida para conta_a_pagar(id_conta_pagar). */
CREATE TABLE baixa_pagar (
 id_baixa INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_baixa DATE NOT NULL,
 valor_pago DECIMAL(12,2) NOT NULL,
 metodo VARCHAR(50) NOT NULL,
 id_conta_pagar INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_baixa),
 KEY ix_baixa_conta (id_conta_pagar),
 KEY ix_baixa_data (data_baixa),
 CONSTRAINT fk_baixa_pagar_conta FOREIGN KEY (id_conta_pagar)
 REFERENCES conta_a_pagar (id_conta_pagar),
 CONSTRAINT ck_baixa_valor CHECK (valor_pago > 0)
) ENGINE=InnoDB COMMENT='Quitação (total ou parcial) de uma conta a pagar';
/* ---------------------------------------------------------------------
 7. CAIXA E CONCILIAÇÃO
 --------------------------------------------------------------------- */
/* MOVIMENTO_CAIXA: registra só dinheiro efetivo. No DER recebe 1 PAGAMENTO
 (entrada) OU 1 BAIXA_PAGAR (saída). [DECISÃO] duas FKs opcionais, exatamente
 uma preenchida (CHECK) e coerente com o tipo; UNIQUE garante 1 movimento
 por pagamento/baixa. */
CREATE TABLE movimento_caixa (
 id_movimento_caixa INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_movimento DATE NOT NULL,
 tipo ENUM('ENTRADA','SAIDA') NOT NULL,
 valor_bruto DECIMAL(12,2) NOT NULL,
 valor_liquido DECIMAL(12,2) NOT NULL,
 id_pagamento INT UNSIGNED NULL,
 id_baixa INT UNSIGNED NULL,
 PRIMARY KEY (id_movimento_caixa),
 UNIQUE KEY uq_movcaixa_pagamento (id_pagamento),
 UNIQUE KEY uq_movcaixa_baixa (id_baixa),
 KEY ix_movcaixa_data (data_movimento),
 CONSTRAINT fk_movcaixa_pagamento FOREIGN KEY (id_pagamento) REFERENCES pagamento (id_pagamento),
 CONSTRAINT fk_movcaixa_baixa FOREIGN KEY (id_baixa) REFERENCES baixa_pagar (id_baixa),
 CONSTRAINT ck_movcaixa_origem CHECK ((id_pagamento IS NULL) <> (id_baixa IS NULL)),
 CONSTRAINT ck_movcaixa_tipo CHECK (
 (tipo = 'ENTRADA' AND id_pagamento IS NOT NULL)
 OR (tipo = 'SAIDA' AND id_baixa IS NOT NULL)),
 CONSTRAINT ck_movcaixa_valores CHECK (valor_bruto >= 0 AND valor_liquido >= 0
 AND valor_liquido <= valor_bruto)
) ENGINE=InnoDB COMMENT='Entrada/saída efetiva de dinheiro';
/* CONCILIACAO: confere o movimento de caixa com o extrato bancário.
 diferenca = valor_extrato - valor_esperado (coluna calculada).
 [DECISÃO] status_conciliacao calculado aplica a RN16:
 ABS(diferenca) > 0,05 => DIVERGENTE. Não consta no DER; adição mínima
 necessária para a RN16. */
CREATE TABLE conciliacao (
 id_conciliacao INT UNSIGNED NOT NULL AUTO_INCREMENT,
 data_conciliacao DATE NOT NULL,
 valor_esperado DECIMAL(12,2) NOT NULL,
 valor_extrato DECIMAL(12,2) NOT NULL,
 diferenca DECIMAL(12,2) GENERATED ALWAYS AS (valor_extrato - valor_esperado) STORED,
 status_conciliacao VARCHAR(10) GENERATED ALWAYS AS (
 CASE WHEN ABS(valor_extrato - valor_esperado) > 0.05
 THEN 'DIVERGENTE' ELSE 'CONCILIADO' END) STORED,
 id_movimento_caixa INT UNSIGNED NOT NULL,
 PRIMARY KEY (id_conciliacao),
 UNIQUE KEY uq_conciliacao_movimento (id_movimento_caixa),
 KEY ix_conciliacao_status (status_conciliacao),
 CONSTRAINT fk_conciliacao_movimento FOREIGN KEY (id_movimento_caixa)
 REFERENCES movimento_caixa (id_movimento_caixa)
) ENGINE=InnoDB COMMENT='Conferência entre o movimento e o extrato bancário (RN16)';
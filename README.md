# Modelagem de Banco de Dados - Pet Shop Pata Feliz

Projeto acadêmico de modelagem de dados para a empresa fictícia **Pata Feliz**, um pet shop que comercializa produtos para animais e oferece serviços como banho e tosa.

> A versão em PDF também está anexada neste repositório: [Banco de dados - Projeto 3.pdf](Banco%20de%20dados%20-%20Projeto%203.pdf).

## Integrantes

- Adrian Cristian dos Santos - RGM 47567210
- Breno da Silva Freire Cordeiro - RGM 47787031
- Emylly Nickolly Viana de Oliveira - RGM 47642785
- Murilo Neves Aguiar - RGM 47443855
- Nickyson Alves Pereira Poliacov - RGM 47765798
- Pedro Henrique Amaral Silva - RGM 47580488
- Renan Rodrigues dos Santos - RGM 47497521
- Richard Fernandes Glogovchan - RGM 47934077
- Thales Alexandre - RGM 47645474

## 1. Sobre a empresa

A Pata Feliz é uma micro ou pequena empresa do segmento pet shop. Atende principalmente clientes que possuem cães e gatos. Comercializa rações, petiscos, brinquedos, produtos de higiene e acessórios, além de oferecer serviços como banho e tosa.

O negócio precisa organizar informações de clientes, animais, produtos, estoque, serviços, funcionários, vendas e pagamentos. A centralização desses dados facilita consultas e reduz erros e duplicidades causados por controles manuais ou separados.

## 2. Processos de negócio

### Atendimento e serviços

**Cliente → cadastro/agendamento → animal → atendimento → pagamento**

O cliente solicita um serviço, como banho ou tosa. O funcionário consulta os horários, registra o agendamento para o animal e, quando o serviço é realizado, registra o atendimento e observações relevantes.

### Venda de produtos

**Cliente → escolha dos produtos → venda → pagamento → atualização do estoque**

O funcionário registra os produtos e as quantidades da compra. Após a venda, o pagamento é registrado e o estoque é atualizado.

### Outros processos contemplados

- Cadastro de clientes e animais;
- Cadastro de funcionários, produtos e serviços;
- Agendamento e realização de serviços;
- Registro de vendas, itens vendidos e pagamentos;
- Controle de entrada e saída de produtos do estoque.

## 3. Problemas identificados

| Problema | Consequência |
|---|---|
| Cadastro manual de clientes | Possibilidade de informações duplicadas |
| Informações dos animais não centralizadas | Dificuldade para consultar o histórico |
| Controle manual do estoque | Erros na quantidade disponível |
| Agendamentos não centralizados | Risco de conflitos de horários |
| Vendas separadas do estoque | Estoque desatualizado |
| Informações de serviços espalhadas | Dificuldade para consultar atendimentos anteriores |
| Pagamentos não integrados às demais informações | Dificuldade para acompanhar as vendas |
| Falta de relatórios | Dificuldade para analisar o negócio |

## 4. Requisitos funcionais

- **RF01:** Cadastrar clientes.
- **RF02:** Cadastrar animais.
- **RF03:** Cadastrar funcionários.
- **RF04:** Cadastrar produtos.
- **RF05:** Cadastrar serviços.
- **RF06:** Permitir realizar agendamentos.
- **RF07:** Registrar os serviços realizados.
- **RF08:** Registrar vendas.
- **RF09:** Registrar os produtos vendidos.
- **RF10:** Registrar pagamentos.
- **RF11:** Controlar o estoque dos produtos.
- **RF12:** Consultar o histórico de serviços de um animal.
- **RF13:** Consultar o histórico de compras de um cliente.
- **RF14:** Consultar os agendamentos.

## 5. Requisitos não funcionais

- **RNF01:** Controlar o acesso dos usuários conforme seu perfil.
- **RNF02:** Proteger os dados dos clientes.
- **RNF03:** Manter registro das operações realizadas pelos usuários.
- **RNF04:** Apresentar consultas em tempo adequado para o atendimento.
- **RNF05:** Oferecer uma interface simples para os funcionários.
- **RNF06:** Armazenar os dados de forma confiável.

## 6. Regras de negócio

- **RN01:** Um cliente pode possuir vários animais.
- **RN02:** Cada animal pertence a apenas um cliente.
- **RN03:** Um cliente pode realizar várias compras.
- **RN04:** Cada compra pertence a apenas um cliente.
- **RN05:** Uma compra deve possuir pelo menos um produto.
- **RN06:** Um produto pode estar presente em várias compras.
- **RN07:** Um produto pode possuir vários fornecedores.
- **RN08:** Um fornecedor pode fornecer vários produtos.
- **RN09:** Um animal pode realizar vários serviços ao longo do tempo.
- **RN10:** Um serviço realizado deve estar associado a um animal.
- **RN11:** Um funcionário pode realizar vários atendimentos.
- **RN12:** Cada atendimento deve ser realizado por um funcionário.

## 7. Restrições e políticas organizacionais

- **RO01:** Somente funcionários autorizados podem alterar o cadastro de produtos.
- **RO02:** Somente funcionários autorizados podem alterar informações de estoque.
- **RO03:** O cadastro de um cliente deve conter informações suficientes para identificá-lo.
- **RO04:** Não deve existir mais de um cadastro para o mesmo cliente.
- **RO05:** Um produto não pode ser vendido sem quantidade disponível em estoque.
- **RO06:** Os dados dos clientes só podem ser acessados por funcionários autorizados.
- **RO07:** O cancelamento de um agendamento deve ser registrado no sistema.

## 8. Entidades e atributos

Os atributos abaixo foram identificados no projeto. Os campos `id_...` são identificadores das respectivas entidades.

| Entidade | Atributos |
|---|---|
| **Cliente** | `id_cliente`, nome, CPF, telefone, e-mail, endereço |
| **Animal** | `id_animal`, nome, espécie, raça, sexo, data de nascimento, observações |
| **Funcionário** | `id_funcionario`, nome, CPF, telefone, cargo |
| **Produto** | `id_produto`, nome, descrição, preço, quantidade em estoque |
| **Fornecedor** | `id_fornecedor`, razão social, telefone, e-mail |
| **Serviço** | `id_servico`, nome, descrição, preço |
| **Agendamento** | `id_agendamento`, data, horário, status |
| **Atendimento** | `id_atendimento`, data do atendimento, observações |
| **Venda** | `id_venda`, data da venda, valor total, status |
| **Item_Venda** | quantidade, preço unitário, subtotal |
| **Pagamento** | `id_pagamento`, data do pagamento, valor, forma de pagamento, status |
| **Estoque** | `id_estoque`, quantidade atual, data de atualização |
| **Fornecimento** | preço de fornecimento, prazo de entrega |

## 9. Relacionamentos e cardinalidades

A cardinalidade expressa quantas ocorrências de uma entidade podem se relacionar com outra. Neste projeto, as regras descrevem as relações a seguir:

| Relacionamento | Cardinalidades | Regra resumida |
|---|---|---|
| Cliente - possui - Animal | Cliente `(0,N)`; Animal `(1,1)` | Um cliente pode não ter animais cadastrados ou ter vários; cada animal pertence a um cliente. |
| Cliente - realiza - Venda | Cliente `(0,N)`; Venda `(1,1)` | Um cliente pode realizar várias vendas; cada venda pertence a um cliente. |
| Venda - possui - Item_Venda | Venda `(1,N)`; Item_Venda `(1,1)` | Uma venda contém pelo menos um item; cada item pertence a uma venda. |
| Produto - aparece em - Item_Venda | Produto `(0,N)`; Item_Venda `(1,1)` | Um produto pode aparecer em vários itens de venda; cada item referencia um produto. |
| Fornecedor - fornece - Produto | Fornecedor `(0,N)`; Produto `(0,N)` | Um fornecedor pode fornecer vários produtos e um produto pode ter vários fornecedores. |
| Produto - possui - Estoque | Produto `(1,1)`; Estoque `(1,1)` | Cada produto possui um controle de estoque. |
| Animal - possui - Agendamento | Animal `(0,N)`; Agendamento `(1,1)` | Um animal pode ter vários agendamentos; cada agendamento se refere a um animal. |
| Agendamento - gera - Atendimento | Agendamento `(0,1)`; Atendimento `(1,1)` | Um agendamento pode ainda não ter sido realizado; cada atendimento registrado vem de um agendamento. |
| Funcionário - realiza - Atendimento | Funcionário `(0,N)`; Atendimento `(1,1)` | Um funcionário pode realizar vários atendimentos; cada atendimento é realizado por um funcionário. |
| Serviço - é utilizado em - Atendimento | Serviço `(0,N)`; Atendimento `(1,1)` | Um serviço pode ser utilizado em vários atendimentos; cada atendimento registra um serviço. |
| Venda - possui - Pagamento | Definida no diagrama do projeto | A venda está relacionada ao pagamento; a cardinalidade não foi detalhada no texto-base. |
| Cliente - solicita - Agendamento | Definida no diagrama do projeto | O cliente solicita o agendamento do serviço. |

### Relacionamento muitos para muitos

**Fornecedor ↔ Produto** é um relacionamento **N:N**: um fornecedor pode fornecer diversos produtos, e um produto pode ser fornecido por diversos fornecedores.

A entidade associativa **Fornecimento** representa essa relação e permite armazenar dados próprios do vínculo, como `preço_fornecimento` e `prazo_entrega`.

A entidade **Item_Venda** também detalha os produtos que compõem uma venda, armazenando quantidade, preço unitário e subtotal.

## 10. Justificativas das entidades associativas

- **Item_Venda:** representa cada produto incluído em uma venda. É necessário para registrar quantidade, preço unitário e subtotal de cada item.
- **Fornecimento:** representa a relação entre fornecedor e produto. Como essa relação é N:N e possui informações próprias, como preço de fornecimento e prazo de entrega, esses dados ficam associados a Fornecimento.

## 11. Arquivos do projeto

- `README.md` - apresentação, processos, requisitos, regras de negócio e resumo da modelagem.
- `Banco de dados - Projeto 3.pdf` - documento completo do projeto, incluindo os fluxogramas, o diagrama, o dicionário de dados e os materiais complementares.

# 📧 Email & Account Analytics — SQL + Looker Studio

## 📌 Visão Geral

Este projeto tem como objetivo analisar a dinâmica de criação de contas e o comportamento de usuários em campanhas de e-mail marketing, utilizando SQL para construção das métricas e Looker Studio para visualização dos resultados.

A análise permite comparar países, identificar os principais mercados e segmentar usuários por diferentes características da conta, apoiando decisões relacionadas à estratégia de comunicação e engajamento.

---

## 🎯 Objetivo do Projeto

* Analisar a criação de contas e atividade de e-mails enviados.
* Avaliar comportamento dos usuários considerando:

  * intervalo de envio (send_interval)
  * verificação da conta
  * status de assinatura
* Comparar desempenho entre países.
* Identificar principais mercados por volume de contas e envio de e-mails.
* Construir métricas agregadas e rankings utilizando funções de janela.
* Criar visualização analítica no Looker Studio.

---

## 🗂️ Estrutura dos Dados

As principais tabelas utilizadas:

* `account`
* `account_session`
* `session`
* `session_params`
* `email_sent`
* `email_open`
* `email_visit`

---

## 🧠 Estratégia da Query

A lógica da consulta foi dividida em etapas utilizando CTEs para separar responsabilidades e facilitar manutenção.

### 1️⃣ Informações únicas por conta

* Identificação da data de criação da conta.
* Definição do país associado à primeira sessão do usuário.

### 2️⃣ Métricas de conta

Cálculo de:

* número de contas criadas (`account_cnt`)

Com detalhamento por:

* data
* país
* intervalo de envio
* verificação
* status de assinatura

### 3️⃣ Métricas de e-mail

Cálculo de:

* e-mails enviados (`sent_msg`)
* e-mails abertos (`open_msg`)
* cliques em links (`visit_msg`)

A data foi calculada a partir da data de criação da conta + deslocamento do envio.

### 4️⃣ União das métricas

As métricas de conta e e-mail foram calculadas separadamente e unidas via:

```sql
UNION ALL
```

Essa abordagem evita conflitos causados por diferentes lógicas de data.

### 5️⃣ Consolidação final

* Agregação das métricas após a união.
* Remoção de registros sem país.

### 6️⃣ Totais por país

Uso de funções de janela:

* total de contas por país
* total de e-mails enviados por país

### 7️⃣ Ranking dos países

Classificação utilizando:

```sql
DENSE_RANK()
```

Ranking baseado em:

* número total de contas
* número total de e-mails enviados

### 8️⃣ Resultado final

Filtro aplicado:

* Top 10 países por contas criadas
  ou
* Top 10 países por volume de e-mails enviados

---

## 📊 Métricas Geradas

* `account_cnt`
* `sent_msg`
* `open_msg`
* `visit_msg`
* `total_country_account_cnt`
* `total_country_sent_cnt`
* `rank_total_country_account_cnt`
* `rank_total_country_sent_cnt`

---

## 📈 Visualização (Looker Studio)

Foi criado um dashboard analítico contendo:

* métricas gerais por país:

  * contas criadas
  * total de e-mails enviados
  * rankings por país
* dinâmica temporal do campo `sent_msg`
* comparação entre mercados principais

A visualização permite analisar rapidamente:

* países com maior base de usuários
* volume de comunicação por mercado
* evolução temporal dos envios

---

## 🛠️ Tecnologias Utilizadas

* BigQuery (SQL)
* CTEs
* Window Functions
* UNION ALL
* Looker Studio

---

## 💼 Principais Aprendizados

* Separação de métricas com diferentes lógicas temporais.
* Uso eficiente de funções analíticas para rankings.
* Estruturação de consultas complexas usando CTEs.
* Construção de dataset pronto para visualização BI.

---

## 📄 Observação

Este projeto foi desenvolvido como prática avançada de SQL Analytics, com foco em modelagem analítica, segmentação de usuários e geração de métricas para tomada de decisão orientada por dados.

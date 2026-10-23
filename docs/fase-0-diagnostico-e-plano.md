# Cérebro do Mundo WP: Fase 0 (diagnóstico e plano)

Data do levantamento: 23/10/2026.
Método: só leitura de metadados (`information_schema`, `pg_stat_user_tables`, `supabase/config.toml`, código das edge functions já existentes) e agregados sem dado pessoal (contagens, somas, cadastros de unidade). Nenhum sistema foi alterado. Não li `.env`, tabelas de credenciais nem colunas com dado pessoal.

---

## 1. Resumo em 10 linhas

1. Os refs do mapa estão **corretos**: conferi 19 no `config.toml` de cada projeto (A200 e Impacto Social ficaram de fora porque estão fora do escopo). O do Jurídico (`cfthgxvwtwguryamlcdx`) também confere, mas esse banco **não é gerenciado pelo Lovable** e não está na sua organização do Supabase, então não consegui ler os metadados.
2. A pasta tem um projeto que não estava no mapa: **Plataforma RH** (`sstfjnlxwuooknchniov`), sobre férias e aniversariantes. É dado pessoal e fica fora por enquanto. O "filial-harmony" não está na pasta.
3. **A chave comum já existe: é o código de posto do Unilab.** DRE, METAS (relatório do Unilab), COMPRAS e Ativos usam o mesmo código ("01"…"99", "9B"…"9Q"). O DRE tem a lista mais completa (114 postos em 09/2026), com nome, marca e hub.
4. O código **é reutilizado ao longo do tempo** (ex.: 87 já foi outra unidade, 89 fechou em 04/2026). A `dim_unidade` precisa de vigência (de/até), não só de um código.
5. "Empresa" tem três níveis diferentes: marca comercial (Endocrimeta, Widal Pacheco, Santa Helena), laboratório/CNPJ (Widal, Pacheco, Endocrimeta, Conte, Santa Helena) e hub (Porto Alegre, Passo Fundo, Lages, Nova Petrópolis, Ibirama). O Cérebro precisa dos três.
6. **Nenhuma das APIs existentes serve como está.** Uma usa chave compartilhada, outra expõe dado pessoal, e duas aceitam escrita com a mesma chave. Recomendo uma função padrão `cerebro-export`, só GET e com allowlist, em cada fonte.
7. O CIQ **não** cobre só a Endocrimeta: também tem equipamentos de HMTR, HDWC, HNP e Passo Fundo.
8. `unilab_sent = false` e `unilab_response` vazio em **100%** dos pedidos dos dois e-commerces (1.679 Endo e 1.052 Widal). O fluxo nunca registra o envio ao Unilab.
9. A Conciliação de Apoios mostra divergência **negativa** de cerca de R$ 2,2 mi no DB Lab (o cobrado ficou abaixo do acordado). Pode ser convenção de sinal ou tabela de preço incompleta. Precisa validar antes de virar alerta.
10. Recomendo um **Supabase próprio** na sua organização para o Cérebro, e não o Lovable Cloud (ver seção 6).

---

## 2. O que estava errado ou incompleto no mapa

| Item do mapa | O que encontrei |
|---|---|
| CIQ "só cobre a Endocrimeta" | 37 equipamentos: Endocrimeta (9), HMTR (10), HDWC (6), HNP (5), PF/Widal (6), mais 1 sem prefixo. Relatórios de 27/07 a 18/10/2026. |
| Ativos `locations` "105, com `numero_loja`" | São 105, mas **`assets.localizacao` é texto livre** (67 valores distintos) e não referencia `locations`. A rota `GET /locations` da `assets-api` devolve esse texto, não `numero_loja`. |
| Ativos `numero_loja` = código Unilab | Vale para quase todos, com estas exceções: 96 = "APOIO PASTEUR" (no Unilab, 96 é São Leopoldo), 87 = "HOMECARE ENDO 2" (no Unilab, Estância Velha), 51 = "Livre", e São Leopoldo, Sapucaia e Wenceslau sem número. |
| Contas Fixas: unidade por CNPJ e nome | `recurring_bills.codigo_posto` existe, mas guarda **nome** e não código. Há uma filial duplicada (COLUMBIA) e uma "nova unidade poa". `grupo` = ENDO/CONTE/WIDAL/PACHECO/OUTRO. |
| DRE `unit_config` (código de 2 caracteres) | Tem só 25 linhas de configuração. As unidades estão em `dre_months.data.units[]` (de 100 a 114 por mês, 13 meses: 09/2025 a 09/2026), com cerca de 30 métricas por unidade. **`unit_regions.regiao` guarda a marca** (Widal/Endocrimeta), não a região. |
| METAS: códigos espelham o Unilab | **Confirmado.** O relatório do Unilab (`group_report_postos`) usa o mesmo código. Mas 22 postos do relatório não existem em `units` do METAS (administrativos, produção, hospitais de apoio, Soledade, Ivoti, Toxilab…), e 5 unidades do METAS não têm código (Vidacard Ibirubá, que é 41, Canoas Medical, que é 89, Venda Digital ×2 e Santa Helena Scola). |
| METAS `postos-faturamento` | Só tem dados de 2026-01 a 2026-10. O histórico de 2025 está em `revenue_entries`, por unidade, sem pedidos nem exames. |
| COMPRAS `units.code` | Bate com o Unilab, com estas exceções: código "1" = Santa Helena Viamópolis (deveria ser 9K) e "UNI-01 Matriz São Paulo", que parece teste. |
| Wiki `clients` = 113 unidades | São 114 linhas, mas cerca de 20 são **departamentos** (COMPRAS, RH, TI, DIREÇÃO WP, FINANCEIRO…). "DIREÇÃO WP" sozinha tem 112 chamados. Hoje há 764 chamados. |
| Avaliação `units` (75) | Também mistura unidades e departamentos. |
| Vagas: "vagas por unidade" | `jobs` **não tem unidade**, só cidade/UF e empresa (4). Dá para medir por cidade e empresa, não por posto, sem mudar o sistema. |
| Conciliação de Apoios: conte/endo/widal | Os laboratórios ali são `endocrimeta`, `pacheco` e `widal` (não há Conte). |
| Notas não localizadas abertas: 7.342 | Hoje são **7.396** (R$ 623,8 mil), sendo 50 sem laboratório. |
| Wiki `dashboard-api` | Devolve só os 100 chamados mais recentes, **sem a unidade** (`client_id`). Não serve para análise por unidade. |
| Wiki `closed-tickets-api` | Devolve `requester_name` e `requester_phone` (dado pessoal) e tem um POST que escreve. **Não pode ser usada pelo Cérebro.** |

Volumes atualizados (pg_stat, aproximados): METAS `group_report_convenios` 14.086; DRE `exame_volumes` 3.181; COMPRAS `purchase_requests` 433 e `stock_movements` 5.149; Contas `bill_payments` 2.771; CONCILIA `lancamentos_unilab` 78.429 e `conciliacoes` 1.965; Apoios `audit_comparison_items` 24.380; CIQ `dismissed_problems` 17.555; Ativos `assets` 3.364; Abertura 8 aberturas e 1.454 itens; Vagas `applications` 4.649; Avaliação `pdis` 590; e-commerces: Endo 1.679 pedidos, Widal 1.052, Santa Helena 9.

---

## 3. A chave de unidade (proposta para `dim_unidade`)

**Fonte mestra:** a lista de postos do Unilab que vem em `dre_months.data.units` (código, nome, marca entre parênteses, hub), complementada pelo relatório do METAS.

```
dim_unidade (unidade_id, codigo_unilab, nome_normalizado, tipo, marca, laboratorio_cnpj_id,
             hub, regiao_comercial, cidade, uf, vigente_de, vigente_ate, situacao)
unidade_alias (fonte, id_na_fonte, nome_na_fonte, unidade_id, metodo, confianca, revisado_por, revisado_em)
```

- `tipo`: posto, hospital, coleta móvel/home care, administrativo, produção/hub técnico, clínica parceira (Vidacard), canal digital, departamento.
- `metodo` do de-para, em ordem: código exato, depois código com vigência, depois nome normalizado exato (sem acento, sem "UNIDADE", sem sufixo de CRBM), depois nome aproximado (trigram ≥ 0,8, só como sugestão e com revisão humana), e por fim manual.
- Os conflitos que encontrei (96, 87, 51, 1, 9K) entram como casos de teste do de-para.

Expectativa de casamento na Fase 1 (estimativa a partir do que vi):

| Fonte | Como casa | Casamento esperado |
|---|---|---|
| DRE, METAS (relatório Unilab), COMPRAS | código | ~100% (com exceções listadas) |
| METAS `units` | código | 79 de 84 (5 sem código) |
| Ativos | `numero_loja` + nome | ~95%, com 4 conflitos para revisar |
| Contas Fixas | nome + cidade + grupo | ~90% por nome |
| Wiki, Avaliação | nome | ~75% (o resto são departamentos, que vão para `dim_setor`) |
| E-commerces | nome + cidade | ~80%, a confirmar |
| Abertura | texto livre | manual (8 registros) |

---

## 4. Empresa, marca e laboratório

| Nível | Valores | Onde aparece |
|---|---|---|
| Marca comercial | Endocrimeta, Widal Pacheco, Santa Helena | e-commerces (`brand`), portal |
| Laboratório / razão social (CNPJ) | Widal (inclui HNP), Pacheco (Central, Ambrósio, Ibirama), Endocrimeta, Conte, Santa Helena | COMPRAS `billing_entities` (8), Contas `grupo`, Conciliações `laboratorio`, nome do posto no DRE |
| Hub / região | Porto Alegre, Passo Fundo, Lages, Nova Petrópolis, Ibirama; regionais comerciais do METAS (10) | DRE `hub`, METAS `regions` |

Dicionário de grafias para `dim_empresa`: `endo`, `endocrimeta`, `ENDO` → Endocrimeta; `widal`, `WIDAL` → Widal; `pacheco`, `PACHECO` → Pacheco; `widal-pacheco` → marca Widal Pacheco; `conte`, `CONTE` → Conte; `santa-helena` → Santa Helena.

Atenção: no DRE, o posto 71 aparece como "GRAVATAÍ (Endocrimeta)", mas no METAS e no Contas Fixas é "CONTE MATRIZ". Ou seja, um posto pode ter marca Endocrimeta e CNPJ Conte. Precisa da sua confirmação (pergunta 4).

---

## 5. APIs existentes: avaliação

| API | Situação | Pode usar? |
|---|---|---|
| METAS `postos-faturamento` | GET, agregado por posto e mês, sem dado pessoal. Usa uma chave única (`EXTERNAL_API_KEY`) compartilhada com o DRE, com comparação simples. | **Sim, provisoriamente.** O ideal é uma chave própria do Cérebro, para revogar sem afetar o DRE. |
| Wiki `dashboard-api` | Só 100 chamados, sem unidade. Grava `last_used_at` a cada chamada. | Não. Precisa de função nova. |
| Wiki `closed-tickets-api` | Expõe nome e telefone do solicitante e tem POST de escrita. | **Não.** |
| Ativos `assets-api` | GET útil, mas **a mesma chave libera o POST de manutenção**, que altera o status do ativo. | Não com essa chave. O Cérebro não deve guardar uma chave que permite escrita. |
| E-commerce `unidades-publicas` | Pública, diretório de unidades (dado institucional). | Sim, para endereço, cidade e horário. Não tem código Unilab. |

### Padrão proposto: `cerebro-export` (uma por fonte, para você aplicar via Lovable)

- Apenas `GET`. Não tem rota de escrita e não grava nada, nem `last_used_at`.
- Header `x-cerebro-key`, validado contra o secret `CEREBRO_READ_KEY`, exclusivo do Cérebro e com comparação em tempo constante.
- `?resource=<nome>&since=<timestamp>&competencia=AAAA-MM&limit=&offset=`, com paginação e carga incremental por `updated_at`.
- Lista fixa de colunas no código (allowlist). Texto livre (descrição, observação, comentário) **não sai**.
- Resposta com `{resource, generated_at, count, items[]}`.

| Fonte | Recursos e colunas permitidas (resumo) |
|---|---|
| METAS | `units`(id, code, name, region_id, inactivated_at); `regions`(id, name); `revenue_entries`(unit_id, year, month, achieved_value); `monthly_goals`(unit_id, year, month, goal_value); `convenios`: agregado de `group_report_convenios` por posto, convênio e mês (somente valores) |
| DRE | `units_month`: `dre_months.data.units[]` com as métricas numéricas; `exame_custos` e `exame_volumes` agregados por mês, mnemônico e posto; `uniab_consumo` por mês e centro de custo |
| COMPRAS | `units`; `billing_entities`(id, lab_name); `purchase_requests`(id, unit_id, status, priority, category, estimated_value, approved_value, created_at, approved_at, delivered_at, billing_entity_id); `closings`(request_id, total_value, created_at); `quotations` agregadas (n, mínimo, máximo); `finance_bills`(id, billing_entity_id, category_id, amount, paid_amount, competence, due_date, paid_at, status); `stock_movements` agregado por unidade, mês, produto e tipo. **Sem** dados bancários, Pix ou CNPJ de fornecedor (só um hash do fornecedor). |
| Contas Fixas | `branches`(id, nome, cidade, grupo, ativo); `bill_payments`(branch_id, tipo, competencia, vencimento, status, valor_previsto, valor_pago, data_pagamento). **Sem** `acesso_login`/`acesso_site`, sem dados de fornecedor. |
| CONCILIA | `conciliacoes`(laboratorio, competencia, status, totais e quantidades); `notas_abertas` agregadas (laboratorio, competencia, resolvida, n, soma); `demonstrativos`(laboratorio, competencia, totais). **Nada** de `lancamentos_unilab` linha a linha (tem nome de paciente). |
| Apoios | `audit_comparisons` (sem `user_id`); itens agregados por competência, laboratório, apoio e código de exame (n, cobrado, acordado, diferença). **Sem** `nome_paciente` nem `numero_pedido`. |
| Wiki | `clients`(id, name, company, region, is_active); `tickets`(id, client_id, category_id, priority, status, created_at, resolved_at, due_date, `asset_patrimony`); `categories`. **Sem** título, descrição ou solicitante. |
| Ativos | `locations`(id, name, numero_loja); `assets`(id, type, status, localizacao, fabricante, modelo, data_compra, valor_compra, codigo_patrimonio); `maintenance` (asset_id, date, type, cost). **Sem** `responsavel`. |
| CIQ | `equipments`(id, name, sector); `reports`(equipment_name, period_start, period_end, total_runs, approved_count, error_count, warning_count); problemas agregados por equipamento, analito e tipo. |
| Abertura | `openings`(id, name, city, region, status, opening_type, inauguration_date); itens agregados por abertura, setor e fase (total, concluídos, bloqueantes abertos, vencidos). |
| E-commerces | pedidos agregados por dia, unidade, status, forma de pagamento e cupom (n, soma, `unilab_sent`). **Nada** do cliente. |
| Vagas | agregado por vaga, empresa, cidade e etapa (n de candidaturas e tempo na etapa). **Sem** candidatos. |
| Avaliação | agregado por ciclo e unidade (respostas esperadas e recebidas, PDIs por status). **Sem** nomes, notas individuais ou comentários. |

---

## 6. Ajustes que proponho na arquitetura

1. **Supabase próprio** na sua organização (já existe a `iilpulcoruskbleurexq`), e não Lovable Cloud. Motivos: migrations versionadas a partir deste repositório (CLI e branches), Vault e `pg_cron` sob nosso controle, acesso pelo Supabase MCP, e isolamento dos apps. A página "Cérebro" no Mundo WP consome a API do Cérebro.
2. **Vigência na `dim_unidade`** (SCD tipo 2), por causa da reutilização de código.
3. **`dim_setor`** para departamentos (TI, RH, Compras…), separada de unidade, porque o Wiki e a Avaliação misturam os dois.
4. **Agregar na origem sempre que possível.** O `raw_*` guarda o payload já filtrado pela allowlist, nunca a tabela inteira.
5. **pgvector não é necessário agora.** O chat responde com SQL sobre `mart`, por ferramentas e somente leitura. Reavaliar na Fase 4, se entrar busca na Wiki.
6. **Qualidade de dado como produto:** uma tabela `mart.qualidade_dados` com os problemas detectados (como os desta seção 2), para virar tarefa de correção nas fontes.

---

## 7. Plano em fases

Estimativas em dias úteis de desenvolvimento, sem contar o tempo de aprovação nem a aplicação das funções no Lovable.

| Fase | Entregas | Esforço | Dependências |
|---|---|---|---|
| **1. Fundação** | Estrutura do repositório (migrations, functions, tests); projeto Supabase; schemas `raw`, `core`, `mart` e `audit` com RLS; `dim_empresa`, `dim_periodo`, `dim_unidade` + `unidade_alias` com vigência; conectores METAS (`postos-faturamento` + `cerebro-export`), Ativos, Wiki e `unidades-publicas`; **relatório de casamento**; testes do de-para | 8 a 10 | Aprovar a criação do projeto; aplicar `cerebro-export` em METAS, Ativos e Wiki |
| **2. Financeiro** | Conectores DRE, COMPRAS, Contas Fixas, CONCILIA e Apoios; `fato_resultado_unidade_mes`, `fato_meta_mes`, `fato_convenio_mes`, `fato_compra`, `fato_conta_fixa`; insights 1 (margem), 2 (meta x realizado com projeção) e 3 (convênios e apoios) | 10 a 12 | Funções nessas 5 fontes; validar o sinal da divergência dos apoios |
| **3. Insights e saídas** | Motor de regras em SQL com testes; narrativa por LLM (só métricas agregadas); página "Cérebro" no Mundo WP; resumos diário e semanal (desligados até sua aprovação); insights 4 a 9 | 12 a 15 | Canal e destinatários; orçamento do LLM |
| **4. Chat, SSO e demais fontes** | Chat com SQL restrito e log; papéis e RLS por região e empresa; Vagas e Avaliação agregadas; e-commerces; desenho do SSO | 15 ou mais | Definição de papéis; decisão sobre SSO |

### Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Fontes alimentadas por planilha (DRE, METAS, CONCILIA) chegam com atraso | Insight desatualizado | Mostrar "dado de até AAAA-MM" em cada métrica e alertar quando a carga atrasar |
| Código de posto reutilizado ou digitado errado | Unidade errada no ranking | Vigência, testes de conflito e relatório de casamento com revisão humana |
| Depender de mudanças via Lovable em 13 projetos | Cronograma | Começar pelas 4 fontes da Fase 1; especificação pronta para colar no prompt do Lovable |
| Chaves compartilhadas e funções com escrita | Segurança | Chave exclusiva do Cérebro, só GET, revogável |
| Divergências que dependem de convenção (apoios) | Alerta falso | Validar com o financeiro antes de ativar a regra |
| LGPD | Alto | Allowlist na origem, sem texto livre, hash de e-mail com salt no Vault, RLS desde o início |

---

## 8. Achados de segurança e qualidade para a TI (sem exploração)

Registro do que vi ao ler código e metadados. Não testei nada.

- `assets-api`: a chave de leitura é a mesma que autoriza o POST de manutenção, que muda o status do ativo.
- `closed-tickets-api`: devolve nome e telefone do solicitante e marca chamados por POST com a mesma chave.
- `postos-faturamento`: uma chave para todos os consumidores e comparação de string simples.
- Contas Fixas: `recurring_bills.acesso_login`/`acesso_site` e `suppliers.portal_login` guardam acesso a portais de fornecedor em tabela de negócio.
- PDV WP: a função `create_admin` está com `verify_jwt = false` (conferir se já está nos chamados abertos).
- E-commerces: `unilab_sent` nunca é marcado como verdadeiro (100% dos pedidos). Pendentes: Widal 193 de 1.052 (18,3%) e Endo 116 de 1.679 (6,9%).
- Aberturas com data de inauguração já passada e ainda "em andamento": Sapucaia (01/07, 8 bloqueantes abertos), Hospital Municipal PF (01/07, 5), Centro Lages (01/07), Novo Administrativo (01/08), Wenceslau (15/09, 5) e Santa Helena (01/10, 5).

---

## 9. Perguntas em aberto

1. ~~**Infraestrutura**~~ Respondida: o Cérebro fica no projeto Supabase `piiozonbqdewleihldwz`. Falta liberar o acesso a ele para o conector desta sessão.
2. **Lista oficial de unidades:** existe uma planilha mestra (código Unilab, CNPJ, nome, marca, região)? Se não existir, posso usar a lista do Unilab que vem no DRE como referência e gerar uma planilha para validação?
3. **Conflitos de código:** o que é o "96 APOIO PASTEUR" e o "87 HOMECARE ENDO 2" no Ativos? O "1 Santa Helena Viamópolis" do COMPRAS é o 9K?
4. **Empresa x marca:** Conte e Santa Helena (POA) são CNPJs próprios com marca Endocrimeta? O posto 14 "SANTA HELENA" de Lages é só um bairro, sem relação com o laboratório Santa Helena?
5. **Usuários e papéis:** quem usa o Cérebro e quais recortes de região e empresa cada um vê? As regionais do METAS (10) são a referência?
6. **Resumos:** quem recebe, com que frequência e por qual canal (e-mail via Resend? WhatsApp por qual provedor?)
7. **LLM:** qual o limite de custo mensal? Minha sugestão: Sonnet para narrativas e chat, Haiku para classificação e resumos curtos, com cache de prompt.
8. **Mudanças nas fontes:** você prefere que eu aplique as `cerebro-export` via Lovable (com sua aprovação, projeto a projeto) ou que eu só entregue as especificações?
9. **Jurídico:** quem administra o banco `cfthgxvwtwguryamlcdx`? Ele entra em alguma fase (somente contagens por laboratório e status)?
10. **Apoios:** a divergência negativa do DB Lab significa "cobrado abaixo do acordado" ou é um efeito de exames sem preço cadastrado?
11. **Santa Helena e Conte desde a Fase 1?** Pelo que vi, eles já aparecem no DRE e no METAS (9G a 9N, 71 a 73), então entram naturalmente pelo código.

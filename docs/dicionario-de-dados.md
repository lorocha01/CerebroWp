# Dicionário de dados

Estado: Fase 1 (fundação). Tabelas de fatos (`mart.fato_*`) entram na Fase 2.

## raw

| Objeto | Descrição |
|---|---|
| `raw.fonte` | Catálogo das fontes: id, nome, ref do projeto Supabase, forma de acesso (`api_existente`, `cerebro_export`, `publica`, `pendente`, `fora_do_escopo`) e fase. |
| `raw.lote_ingestao` | Uma linha por execução de conector: fonte, recurso, parâmetros, status, quantidades, erro. |
| `raw.registro` | Uma linha por **versão** de cada registro de fonte (`fonte_id`, `recurso`, `chave_fonte`). `payload_hash` é o SHA-256 do JSON canônico; só a versão mais recente fica com `vigente = true`. |
| `raw.registrar(fonte, recurso, chave, payload, lote)` | Grava um registro. Retorna `true` se é novo ou mudou; o mesmo conteúdo não gera versão. |

## core

| Objeto | Descrição |
|---|---|
| `core.dim_periodo` | Um mês por linha, de 2020-01 a 2032-12. `competencia` (date, dia 1), `competencia_iso` ('AAAA-MM'), `competencia_br` ('MM/AAAA'), trimestre, semestre, dias no mês. |
| `core.dim_empresa` | Grupo, marcas (Endocrimeta, Widal Pacheco, Santa Helena) e laboratórios (Endocrimeta, Conte, Widal, Pacheco, Santa Helena). Laboratório aponta para a marca. CNPJ entra pela ingestão do COMPRAS. |
| `core.empresa_alias` | Grafias vistas nas fontes (`endo`, `widal-pacheco`, `PACHECO`…) por tipo (marca ou laboratório). |
| `core.dim_hub` | Hubs técnicos: Porto Alegre, Passo Fundo, Nova Petrópolis, Lages, Ibirama. |
| `core.dim_regiao` | Regiões comerciais (fonte: METAS). Populada pela ingestão. |
| `core.dim_setor` / `core.setor_alias` | Departamentos (TI, RH, Compras, Direção…) que aparecem como "unidade" no Wiki e na Avaliação. |
| `core.dim_unidade` | Unidade mestra: nome, `nome_normalizado` (gerado), tipo (`posto`, `hospital`, `coleta_movel`, `administrativo`, `producao`, `clinica_parceira`, `canal_digital`), laboratório, marca, hub, região, cidade, UF, situação, `classificacao_origem` e `validado`. |
| `core.unidade_codigo` | Código de posto do Unilab por unidade, com `vigencia` (daterange). O mesmo código não pode ter vigências sobrepostas. |
| `core.unidade_alias` | De-para: uma linha por unidade como existe em cada fonte. `metodo` (código, código em conflito, nome exato, nome aproximado, ambíguo, setor, manual, sem par), `confianca`, `status` e `candidatos`. |
| `core.v_unidade_alias_efetivo` | Só os de-para que valem para os fatos (`automatico` ou `confirmado`). |

### Funções

| Função | O que faz |
|---|---|
| `core.normaliza_nome(texto)` | Nome comparável: sem acento, maiúsculo, sem CRBM/CRF/CRBIO, sem "(Widal)" etc., sem "UNIDADE"/"LABORATÓRIO"/"INATIVO", com ADM, HOSP, PCLINICA, HOMECARE e VCARD expandidos. |
| `core.normaliza_competencia(texto)` | 'MM/AAAA', 'AAAA-MM', 'AAAA-MM-DD', ISO ou 'AAAAMM' para o dia 1 do mês. Inválido vira `null`. |
| `core.resolve_empresa(grafia, tipo)` | Grafia de fonte para `empresa_id`. |
| `core.casar_unidade(codigo, nome, data)` | Resolve a unidade sem gravar. Sem `data` = cadastro (considera todas as unidades e a vigência mais recente de cada código); com `data` = fato daquela competência. |
| `core.registrar_alias(fonte, id, nome, codigo, data)` | Grava o de-para. Nunca sobrescreve `confirmado` ou `rejeitado`. |
| `core.revisar_alias(alias_id, decisao, revisor, unidade_id, setor_id)` | Decisão humana (confirmar, apontar outra unidade/setor, rejeitar). Registra em `audit.evento`. |

### Regras do casamento

1. Sem código e com nome de departamento conhecido: setor.
2. Código Unilab encontrado e nome compatível (semelhante ou contido): `codigo`, entra direto. Nome incompatível: `codigo_conflito`, vai para revisão com a unidade do código como sugestão.
3. Nome igual ao mestre ou a um nome já aceito em outra fonte, apontando para uma só unidade: `nome_exato`, entra direto.
4. Nome parecido (trigramas ≥ 0,45, ou ≥ 0,60 se for uma palavra só) com folga de 0,08 para o segundo colocado: `nome_aproximado`, vai para revisão. Sem folga: `ambiguo`. Abaixo do mínimo: `sem_par`.

Como nomes aceitos viram apelidos da unidade, a ingestão deve rodar primeiro as fontes com código (DRE, METAS, COMPRAS, Ativos) e depois as que só têm nome (Contas Fixas, Wiki, Avaliação, e-commerces).

## mart

| Objeto | Descrição |
|---|---|
| `mart.v_relatorio_casamento` | Por fonte: total, casadas (unidade e setor), sugeridas, a revisar, sem par, conflitos de código, % casado e confiança média. |
| `mart.v_casamento_pendencias` | Fila de revisão humana com a unidade sugerida e os três melhores candidatos. |
| `mart.v_cobertura_unidade` | Para cada unidade mestra, em quais fontes ela aparece. |

## audit

| Objeto | Descrição |
|---|---|
| `audit.evento` | Quem fez o quê e quando (`ator`, `acao`, `alvo`, `detalhes`). |

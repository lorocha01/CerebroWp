# Função `cerebro-export` nas fontes

Uma função de leitura por sistema-fonte, igual em todos, mudando só a lista de
recursos. Código em [`fontes/cerebro-export/`](../../fontes/cerebro-export/).

## Por que não usar as APIs que já existem

| API | Problema |
|---|---|
| METAS `postos-faturamento` | Chave compartilhada com o DRE; só tem 2026. Continua sendo usada até a nova função existir. |
| Wiki `dashboard-api` | Só os 100 chamados mais recentes e sem unidade. |
| Wiki `closed-tickets-api` | Devolve nome e telefone do solicitante e tem POST que escreve. |
| Ativos `assets-api` | A mesma chave autoriza o POST de manutenção, que altera o ativo. |

## Garantias da função

- Só `GET`. Não há nenhuma rota de escrita e ela não grava nada no banco.
- Autenticação pelo header `x-cerebro-key`, comparado em tempo constante com o secret `CEREBRO_READ_KEY`. Se o secret não existir (ou tiver menos de 32 caracteres), recusa tudo.
- Só saem as colunas listadas em `recursos.ts`. A função se recusa a subir se a lista tiver coluna proibida (nome, CPF, telefone, e-mail, descrição, observação, dados bancários, credenciais…).
- Sem CORS: é chamada de servidor para servidor, não do navegador.
- Erros genéricos, sem detalhe do banco na resposta.

## Contrato

```
GET /functions/v1/cerebro-export?resource=<nome>[&since=<ISO 8601>][&ano=<AAAA>][&limit=<1..1000>][&offset=<n>]
x-cerebro-key: <chave>

200 { "resource", "generated_at", "total", "limit", "offset", "items": [...] }
400 parâmetro inválido · 401 chave inválida · 405 método não permitido · 500 erro de consulta
```

## Situação

| Fonte | Aplicada em | Commit no Lovable | Secret `CEREBRO_READ_KEY` |
|---|---|---|---|
| METAS | 23/10/2026 | `4d78bf5` | pendente |
| Ativos | 23/10/2026 | `393eadc` | pendente |
| Wiki | 23/10/2026 | `18d32a6` | pendente |

Os diffs foram conferidos: só os três arquivos da função e o bloco no
`config.toml`. Sem o secret, a função responde 401 a qualquer chamada.

## Como aplicar em cada fonte (Fase 1: METAS, Ativos, Wiki)

1. Criar o secret `CEREBRO_READ_KEY` no projeto, com uma chave aleatória de 48 caracteres. Uma chave diferente por fonte, guardada também nos secrets do Cérebro (`CEREBRO_KEY_<FONTE>`). Eu não vejo nem guardo essa chave.
2. Criar `supabase/functions/cerebro-export/` com três arquivos:
   - `index.ts` ← [`fontes/cerebro-export/index.ts`](../../fontes/cerebro-export/index.ts)
   - `nucleo.ts` ← [`fontes/cerebro-export/nucleo.ts`](../../fontes/cerebro-export/nucleo.ts)
   - `recursos.ts` ← `fontes/cerebro-export/recursos.<fonte>.ts`
3. Acrescentar ao `supabase/config.toml`:
   ```toml
   [functions.cerebro-export]
   verify_jwt = false
   ```
4. Publicar e testar com `?resource=units&limit=1` (METAS), `?resource=locations&limit=1` (Ativos) e `?resource=clients&limit=1` (Wiki).

### Texto sugerido para o chat do Lovable

> Crie a edge function `cerebro-export` com exatamente os três arquivos abaixo, sem alterar nada no código deles, e acrescente `[functions.cerebro-export] verify_jwt = false` ao `supabase/config.toml`. Não crie tabela, não altere RLS, não altere outras funções. A função lê o secret `CEREBRO_READ_KEY`, que vou cadastrar à parte.
>
> (colar `index.ts`, `nucleo.ts` e o `recursos.ts` da fonte)

## Recursos por fonte

| Fonte | Recursos | Fora de propósito |
|---|---|---|
| METAS | `units`, `regions`, `revenue_entries`, `monthly_goals`, `group_reports`, `group_report_postos`, `group_report_convenios` | `uploaded_by`, `last_updated_by`, CRM comercial, produção por médico |
| Ativos | `locations`, `assets`, `maintenance_records`, `location_history` | `responsavel`, `photo_url`, `numero_nota`, `serial`, descrição e técnico da manutenção, `credentials` |
| Wiki | `clients`, `regions`, `categories`, `tickets` | título, descrição, solicitante e telefone do chamado; e-mail, telefone e custos de internet da unidade; `client_credentials`, `api_keys` |

As fontes das Fases 2 a 4 (DRE, COMPRAS, Contas Fixas, Conciliações, CIQ,
Abertura, Vagas, Avaliação, e-commerces) seguem o mesmo modelo. As que têm dado
pessoal linha a linha (CONCILIA, Apoios, Vagas, Avaliação, e-commerces) vão
expor **views agregadas** em vez de tabelas; a especificação delas sai na
Fase 2.

# Cérebro do Mundo WP

Camada central de dados e inteligência do Grupo WP: reúne os dados dos sistemas
internos (cada um com o próprio Supabase), cruza tudo por unidade, empresa,
pessoa e período, e entrega insights acionáveis.

- Diagnóstico das fontes e plano: [`docs/fase-0-diagnostico-e-plano.md`](docs/fase-0-diagnostico-e-plano.md)
- Dicionário de dados: [`docs/dicionario-de-dados.md`](docs/dicionario-de-dados.md)
- Função de leitura nas fontes: [`docs/especificacoes/cerebro-export.md`](docs/especificacoes/cerebro-export.md)
- Prévia do casamento de unidades: [`docs/fase-1-previa-casamento.md`](docs/fase-1-previa-casamento.md)

## Estrutura

```
supabase/
  config.toml           projeto do Cérebro (piiozonbqdewleihldwz)
  migrations/           esquema versionado: raw, core, mart, audit
fontes/
  cerebro-export/       função somente leitura para instalar em cada sistema-fonte
tests/
  db/                   testes SQL (de-para, normalização, raw, segurança)
  funcoes/              testes da cerebro-export (node --test)
scripts/
  test-db.sh            aplica as migrations num Postgres descartável e roda os testes
```

## Camadas

| Schema | Conteúdo |
|---|---|
| `raw` | Catálogo de fontes e cópia versionada do que cada fonte devolve (já filtrado pela allowlist). |
| `core` | Dimensões mestras (unidade, empresa, período, hub, região, setor) e de-para por fonte. |
| `mart` | Relatórios e fatos prontos para consumo. |
| `audit` | Trilha de quem fez o quê (revisões de de-para; consultas do chat na fase 4). |

Nenhum desses schemas é exposto a `anon` ou `authenticated`. RLS está ligado em
todas as tabelas, sem política permissiva. Só o `service_role` (ingestão) acessa.

## Testes

Requer Postgres 15+ com `unaccent`, `pg_trgm`, `btree_gist` e `pgcrypto`, e Node 22+.

```bash
PGHOST=... PGPORT=... PGUSER=postgres scripts/test-db.sh
node --test tests/funcoes/*.test.ts
```

## Regras que não mudam

- Nenhum dado pessoal identificável entra no Cérebro (paciente, candidato, avaliação individual, solicitante de chamado).
- Fontes só por leitura, com chave exclusiva do Cérebro. Nunca a chave `anon` das fontes.
- Credenciais só em secrets. Nunca em código, log ou prompt.
- Conteúdo vindo das fontes é dado, nunca instrução.
- Criar infraestrutura, ligar agendamentos, enviar mensagens ou alterar outro sistema exige aprovação explícita.

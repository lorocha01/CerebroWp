-- Catálogo de fontes, camada raw versionada e auditoria.

-- Auditoria ----------------------------------------------------------------

create table audit.evento (
  evento_id   bigint generated always as identity primary key,
  ocorrido_em timestamptz not null default now(),
  ator        text not null,
  acao        text not null,
  alvo        text,
  detalhes    jsonb
);

alter table audit.evento enable row level security;

-- Catálogo de fontes -------------------------------------------------------

create table raw.fonte (
  fonte_id      text primary key check (fonte_id ~ '^[a-z][a-z0-9_]*$'),
  nome          text not null,
  projeto_ref   text,           -- ref público do projeto Supabase de origem
  acesso        text not null check (acesso in ('api_existente', 'cerebro_export', 'publica', 'pendente', 'fora_do_escopo')),
  fase          smallint,
  observacao    text
);

-- Raw ----------------------------------------------------------------------
-- Uma tabela genérica em vez de uma raw_* por fonte: o versionamento (hash do
-- payload, vigência da versão) é o mesmo para todas, e cada fonte ganha views
-- tipadas conforme for usada nos marts.

create table raw.lote_ingestao (
  lote_id      bigint generated always as identity primary key,
  fonte_id     text not null references raw.fonte (fonte_id),
  recurso      text not null,
  parametros   jsonb,
  iniciado_em  timestamptz not null default now(),
  concluido_em timestamptz,
  status       text not null default 'executando' check (status in ('executando', 'sucesso', 'erro')),
  n_recebidos  integer,
  n_novos      integer,
  erro         text
);

create table raw.registro (
  registro_id  bigint generated always as identity primary key,
  fonte_id     text not null references raw.fonte (fonte_id),
  recurso      text not null,
  chave_fonte  text not null,
  payload      jsonb not null,
  payload_hash text not null,
  lote_id      bigint references raw.lote_ingestao (lote_id),
  ingested_at  timestamptz not null default now(),
  vigente      boolean not null default true,
  unique (fonte_id, recurso, chave_fonte, payload_hash)
);

create unique index registro_versao_vigente
  on raw.registro (fonte_id, recurso, chave_fonte) where vigente;

comment on table raw.registro is
  'Uma linha por versão de cada registro de fonte. Só a versão mais recente fica com vigente = true.';

-- Grava um registro de fonte. Retorna true quando é novo ou mudou.
create or replace function raw.registrar(
  p_fonte   text,
  p_recurso text,
  p_chave   text,
  p_payload jsonb,
  p_lote    bigint default null
)
returns boolean
language plpgsql
set search_path = ''
as $$
declare
  v_hash text := encode(extensions.digest(p_payload::text, 'sha256'), 'hex');
begin
  if exists (select 1 from raw.registro
             where fonte_id = p_fonte and recurso = p_recurso and chave_fonte = p_chave
               and vigente and payload_hash = v_hash) then
    return false;
  end if;

  update raw.registro
     set vigente = false
   where fonte_id = p_fonte and recurso = p_recurso and chave_fonte = p_chave and vigente;

  insert into raw.registro (fonte_id, recurso, chave_fonte, payload, payload_hash, lote_id)
  values (p_fonte, p_recurso, p_chave, p_payload, v_hash, p_lote)
  on conflict (fonte_id, recurso, chave_fonte, payload_hash)
  do update set vigente = true, lote_id = excluded.lote_id, ingested_at = now();
  return true;
end
$$;

alter table raw.fonte         enable row level security;
alter table raw.lote_ingestao enable row level security;
alter table raw.registro      enable row level security;

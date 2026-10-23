-- Unidade mestra, código Unilab com vigência e de-para por fonte.
--
-- O código de posto do Unilab é a chave comum entre DRE, METAS, COMPRAS e
-- Ativos, mas já foi reutilizado por unidades diferentes ao longo do tempo.
-- Por isso o código fica em tabela própria, com período de vigência.

create table core.dim_unidade (
  unidade_id           uuid primary key default gen_random_uuid(),
  nome                 text not null,
  nome_normalizado     text generated always as (core.normaliza_nome(nome)) stored,
  tipo                 text not null check (tipo in (
                         'posto', 'hospital', 'coleta_movel', 'administrativo',
                         'producao', 'clinica_parceira', 'canal_digital')),
  laboratorio_id       text references core.dim_empresa (empresa_id),
  marca_id             text references core.dim_empresa (empresa_id),
  hub_id               text references core.dim_hub (hub_id),
  regiao_id            uuid references core.dim_regiao (regiao_id),
  cidade               text,
  uf                   char(2),
  situacao             text not null default 'ativa' check (situacao in ('ativa', 'inativa', 'em_abertura')),
  classificacao_origem text,
  validado             boolean not null default false,
  criado_em            timestamptz not null default now(),
  atualizado_em        timestamptz not null default now()
);

comment on column core.dim_unidade.classificacao_origem is
  'Como tipo, laboratório e marca foram definidos (ex.: nome_unilab, regra_hub, contas_fixas). Enquanto validado = false, é provisório.';

create index dim_unidade_nome_trgm on core.dim_unidade using gin (nome_normalizado extensions.gin_trgm_ops);

create table core.unidade_codigo (
  codigo_unilab text not null check (codigo_unilab ~ '^[0-9][0-9A-Z]$'),
  unidade_id    uuid not null references core.dim_unidade (unidade_id) on delete cascade,
  vigencia      daterange not null default daterange(null, null),
  origem        text,
  primary key (codigo_unilab, vigencia),
  constraint unidade_codigo_sem_sobreposicao exclude using gist (codigo_unilab with =, vigencia with &&)
);

comment on table core.unidade_codigo is
  'Código de posto do Unilab por unidade, com vigência. Dois períodos do mesmo código não podem se sobrepor.';

-- De-para por fonte. Uma linha por unidade (ou setor) como ela existe na fonte.
create table core.unidade_alias (
  alias_id        bigint generated always as identity primary key,
  fonte           text not null,
  id_na_fonte     text not null,
  nome_na_fonte   text,
  codigo_na_fonte text,
  unidade_id      uuid references core.dim_unidade (unidade_id),
  setor_id        text references core.dim_setor (setor_id),
  metodo          text not null check (metodo in (
                    'codigo', 'codigo_conflito', 'nome_exato', 'nome_aproximado',
                    'ambiguo', 'setor', 'manual', 'sem_par')),
  confianca       numeric(4, 3) not null check (confianca between 0 and 1),
  status          text not null check (status in ('automatico', 'sugerido', 'revisar', 'confirmado', 'rejeitado')),
  candidatos      jsonb,
  revisado_por    text,
  revisado_em     timestamptz,
  atualizado_em   timestamptz not null default now(),
  unique (fonte, id_na_fonte),
  check (unidade_id is null or setor_id is null)
);

comment on column core.unidade_alias.status is
  'automatico/confirmado entram nos fatos; sugerido e revisar aguardam revisão humana; rejeitado nunca é sobrescrito pela ingestão.';

-- Semelhança entre dois nomes já normalizados (0 a 1), usada para ordenar
-- candidatos. É simétrica de propósito: dar crédito a "nome contido" fazia
-- "SANTA HELENA SALGADO FILHO" preferir o posto "SANTA HELENA" de Lages.
create or replace function core.score_nome(a text, b text)
returns numeric
language sql immutable parallel safe
set search_path = ''
as $$ select round(extensions.similarity(a, b)::numeric, 3) $$;

-- Quando o código Unilab já bate, basta o nome não contradizer: aceita nome
-- contido ("HMTR - TEREZA RAMOS" x "HMTR", "CLINICA HIGIA" x "HIGIA").
create or replace function core.nomes_compativeis(a text, b text)
returns boolean
language sql immutable parallel safe
set search_path = ''
as $$
  select greatest(extensions.similarity(a, b),
                  extensions.word_similarity(a, b),
                  extensions.word_similarity(b, a)) >= 0.6
$$;

-- Nomes pelos quais cada unidade é conhecida: o nome mestre e os nomes de
-- fonte já aceitos (automático ou confirmado). Com data, ficam de fora as
-- unidades cujo código não vale nela; sem data (cadastro), entram todas.
create or replace function core.nomes_unidade(p_data date default null)
returns table (unidade_id uuid, nome_normalizado text)
language sql stable
set search_path = ''
as $$
  with vigentes as (
    select u.unidade_id, u.nome_normalizado
    from core.dim_unidade u
    where p_data is null
       or not exists (select 1 from core.unidade_codigo uc where uc.unidade_id = u.unidade_id)
       or exists (select 1 from core.unidade_codigo uc
                  where uc.unidade_id = u.unidade_id and uc.vigencia @> p_data)
  )
  select v.unidade_id, v.nome_normalizado from vigentes v
  union
  select a.unidade_id, core.normaliza_nome(a.nome_na_fonte)
  from core.unidade_alias a
  join vigentes v on v.unidade_id = a.unidade_id
  where a.status in ('automatico', 'confirmado')
    and core.normaliza_nome(a.nome_na_fonte) is not null
$$;

-- Unidade dona de um código na data; sem data, a da vigência mais recente.
create or replace function core.unidade_do_codigo(p_codigo text, p_data date default null)
returns uuid
language sql stable
set search_path = ''
as $$
  select uc.unidade_id
  from core.unidade_codigo uc
  where uc.codigo_unilab = upper(btrim(p_codigo))
    and (p_data is null or uc.vigencia @> p_data)
  order by upper_inf(uc.vigencia) desc, upper(uc.vigencia) desc
  limit 1
$$;

-- Código de uma unidade na data; sem data, o da vigência mais recente.
create or replace function core.codigo_da_unidade(p_unidade_id uuid, p_data date default null)
returns text
language sql stable
set search_path = ''
as $$
  select uc.codigo_unilab
  from core.unidade_codigo uc
  where uc.unidade_id = p_unidade_id
    and (p_data is null or uc.vigencia @> p_data)
  order by upper_inf(uc.vigencia) desc, upper(uc.vigencia) desc
  limit 1
$$;

-- Casa uma unidade de uma fonte com a unidade mestra. Não grava nada.
--
-- Ordem: setor conhecido (sem código); código Unilab, conferido pelo nome;
-- nome exato (mestre ou apelido aceito); nome aproximado com folga para o
-- segundo colocado.
--
-- p_data: competência do fato que está sendo casado. Para cadastro (a unidade
-- como ela existe na fonte, sem data), deixe nulo.
create or replace function core.casar_unidade(
  p_codigo text,
  p_nome   text,
  p_data   date default null
)
returns table (unidade_id uuid, setor_id text, metodo text, confianca numeric, candidatos jsonb)
language plpgsql stable
set search_path = ''
as $$
#variable_conflict use_column
declare
  c_folga_minima    constant numeric := 0.08;  -- distância mínima para o 2º colocado
  v_nome   text := core.normaliza_nome(p_nome);
  -- Abaixo disso, sem par. Nome de uma palavra só ("MATRIZ") exige mais.
  c_score_minimo    constant numeric := case when v_nome ~ ' ' then 0.45 else 0.60 end;
  v_codigo text := nullif(upper(btrim(p_codigo)), '');
  v_setor  text;
  v_unid   uuid;
  v_top    jsonb;
  v_n_exato int;
  v_best   numeric;
  v_second numeric;
begin
  -- Três melhores candidatos por nome (pontuação = melhor nome conhecido da unidade).
  with pontuados as (
    select n.unidade_id, max(core.score_nome(v_nome, n.nome_normalizado)) as score
    from core.nomes_unidade(p_data) n
    where v_nome is not null
    group by n.unidade_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'unidade_id', p.unidade_id,
           'codigo', core.codigo_da_unidade(p.unidade_id, p_data),
           'nome', u.nome,
           'score', p.score) order by p.score desc, u.nome), '[]'::jsonb)
    into v_top
  from (select * from pontuados order by score desc limit 3) p
  join core.dim_unidade u on u.unidade_id = p.unidade_id;

  -- 1. Setor (departamento), só quando não há código.
  if v_codigo is null then
    select s.setor_id into v_setor from core.setor_alias s where s.nome_normalizado = v_nome;
    if v_setor is not null then
      return query select null::uuid, v_setor, 'setor'::text, 1.000::numeric, null::jsonb;
      return;
    end if;
  end if;

  -- 2. Código Unilab vigente na data.
  if v_codigo is not null then
    v_unid := core.unidade_do_codigo(v_codigo, p_data);

    if v_unid is not null then
      if v_nome is null
         or exists (select 1 from core.nomes_unidade(p_data) n
                    where n.unidade_id = v_unid
                      and core.nomes_compativeis(v_nome, n.nome_normalizado)) then
        return query select v_unid, null::text, 'codigo'::text, 1.000::numeric, null::jsonb;
      else
        -- O código existe, mas o nome não confirma: fica como sugestão para revisão.
        return query select v_unid, null::text, 'codigo_conflito'::text, 0.500::numeric,
          jsonb_build_object('pelo_codigo', v_codigo, 'pelo_nome', v_top);
      end if;
      return;
    end if;
  end if;

  if v_nome is null then
    return query select null::uuid, null::text, 'sem_par'::text, 0.000::numeric, null::jsonb;
    return;
  end if;

  -- 3. Nome exato (mestre ou apelido aceito), desde que aponte para uma só unidade.
  select count(distinct n.unidade_id), min(n.unidade_id::text)::uuid
    into v_n_exato, v_unid
  from core.nomes_unidade(p_data) n
  where n.nome_normalizado = v_nome;

  if v_n_exato = 1 then
    return query select v_unid, null::text, 'nome_exato'::text, 0.950::numeric, null::jsonb;
    return;
  end if;

  -- 4. Nome aproximado. Pontuação 1 com folga equivale a nome exato
  -- (mesmas palavras em outra ordem: "CACHOEIRINHA LAB SANTA HELENA").
  v_best   := coalesce((v_top->0->>'score')::numeric, 0);
  v_second := coalesce((v_top->1->>'score')::numeric, 0);

  if v_n_exato = 0 and v_best = 1 and v_second < 1 then
    return query select (v_top->0->>'unidade_id')::uuid, null::text, 'nome_exato'::text, 0.950::numeric, null::jsonb;
  elsif v_n_exato > 1 or (v_best >= c_score_minimo and v_best - v_second < c_folga_minima) then
    return query select null::uuid, null::text, 'ambiguo'::text, v_best, v_top;
  elsif v_best >= c_score_minimo then
    return query select (v_top->0->>'unidade_id')::uuid, null::text, 'nome_aproximado'::text, v_best, v_top;
  else
    return query select null::uuid, null::text, 'sem_par'::text, v_best, v_top;
  end if;
end
$$;

comment on function core.casar_unidade(text, text, date) is
  'Resolve uma unidade de fonte para a unidade mestra. Não grava nada; ver core.registrar_alias.';

-- Grava (ou atualiza) o de-para de uma unidade de fonte.
-- Decisões humanas (confirmado/rejeitado) nunca são sobrescritas.
create or replace function core.registrar_alias(
  p_fonte  text,
  p_id     text,
  p_nome   text,
  p_codigo text default null,
  p_data   date default null
)
returns core.unidade_alias
language plpgsql
set search_path = ''
as $$
declare
  r core.unidade_alias;
  m record;
  v_status text;
begin
  select * into m from core.casar_unidade(p_codigo, p_nome, p_data);

  v_status := case m.metodo
                when 'codigo' then 'automatico'
                when 'nome_exato' then 'automatico'
                when 'setor' then 'automatico'
                when 'nome_aproximado' then 'sugerido'
                else 'revisar'
              end;

  insert into core.unidade_alias as a
    (fonte, id_na_fonte, nome_na_fonte, codigo_na_fonte, unidade_id, setor_id, metodo, confianca, status, candidatos)
  values
    (p_fonte, p_id, p_nome, nullif(btrim(p_codigo), ''), m.unidade_id, m.setor_id, m.metodo, m.confianca, v_status, m.candidatos)
  on conflict (fonte, id_na_fonte) do update
    set nome_na_fonte   = excluded.nome_na_fonte,
        codigo_na_fonte = excluded.codigo_na_fonte,
        unidade_id      = excluded.unidade_id,
        setor_id        = excluded.setor_id,
        metodo          = excluded.metodo,
        confianca       = excluded.confianca,
        status          = excluded.status,
        candidatos      = excluded.candidatos,
        atualizado_em   = now()
    where a.status not in ('confirmado', 'rejeitado')
  returning * into r;

  if r.alias_id is null then
    select * into r from core.unidade_alias where fonte = p_fonte and id_na_fonte = p_id;
  end if;
  return r;
end
$$;

-- Revisão humana de um de-para (confirmar, apontar outra unidade/setor ou rejeitar).
create or replace function core.revisar_alias(
  p_alias_id   bigint,
  p_decisao    text,
  p_revisor    text,
  p_unidade_id uuid default null,
  p_setor_id   text default null
)
returns core.unidade_alias
language plpgsql
set search_path = ''
as $$
declare
  r core.unidade_alias;
begin
  if p_decisao not in ('confirmado', 'rejeitado') then
    raise exception 'decisão inválida: % (use confirmado ou rejeitado)', p_decisao;
  end if;
  if p_decisao = 'confirmado' and p_unidade_id is not null and p_setor_id is not null then
    raise exception 'informe unidade ou setor, não os dois';
  end if;

  update core.unidade_alias a
     set status       = p_decisao,
         metodo       = case when p_unidade_id is not null or p_setor_id is not null then 'manual' else a.metodo end,
         unidade_id   = case when p_decisao = 'rejeitado' then null
                             when p_unidade_id is not null or p_setor_id is not null then p_unidade_id
                             else a.unidade_id end,
         setor_id     = case when p_decisao = 'rejeitado' then null
                             when p_unidade_id is not null or p_setor_id is not null then p_setor_id
                             else a.setor_id end,
         confianca    = case when p_decisao = 'confirmado' then 1 else a.confianca end,
         revisado_por = p_revisor,
         revisado_em  = now(),
         atualizado_em = now()
   where a.alias_id = p_alias_id
  returning * into r;

  if r.alias_id is null then
    raise exception 'alias % não encontrado', p_alias_id;
  end if;
  if p_decisao = 'confirmado' and r.unidade_id is null and r.setor_id is null then
    raise exception 'para confirmar um alias sem par, informe a unidade ou o setor';
  end if;

  insert into audit.evento (ator, acao, alvo, detalhes)
  values (p_revisor, 'revisar_alias', 'core.unidade_alias:' || p_alias_id,
          jsonb_build_object('decisao', p_decisao, 'unidade_id', r.unidade_id, 'setor_id', r.setor_id));
  return r;
end
$$;

-- De-para que vale para os fatos.
create view core.v_unidade_alias_efetivo
with (security_invoker = true) as
select fonte, id_na_fonte, codigo_na_fonte, unidade_id, setor_id, metodo, confianca
from core.unidade_alias
where status in ('automatico', 'confirmado');

alter table core.dim_unidade    enable row level security;
alter table core.unidade_codigo enable row level security;
alter table core.unidade_alias  enable row level security;

-- Dimensões mestras: período, empresa (grupo, marca e laboratório), hub, região e setor.

-- Normalização -------------------------------------------------------------

-- unaccent() não é imutável; este invólucro fixa o dicionário para poder ser
-- usado em colunas geradas e índices.
create or replace function core.f_unaccent(p text)
returns text
language sql immutable parallel safe strict
set search_path = ''
as $$ select extensions.unaccent('extensions.unaccent'::regdictionary, p) $$;

-- Nome de unidade comparável entre sistemas: sem acento, maiúsculo, sem
-- registro profissional (CRBM/CRF/CRBIO), sem marcador de laboratório entre
-- parênteses, sem palavras de ruído ("UNIDADE", "LABORATÓRIO", "INATIVO") e com
-- abreviações comuns expandidas (ADM, HOSP, VCARD...).
create or replace function core.normaliza_nome(p text)
returns text
language plpgsql immutable parallel safe
set search_path = ''
as $$
declare
  v text := upper(core.f_unaccent(coalesce(p, '')));
begin
  v := regexp_replace(v, '\s*-?\s*(CRBM|CRF|CRBIO)[^A-Z].*$', '', 'g');
  v := regexp_replace(v, '\((WIDAL|PACHECO|ENDOCRIMETA|ENDO|CONTE|FECHADO)\)', ' ', 'g');
  v := regexp_replace(v, '[^A-Z0-9]+', ' ', 'g');
  v := regexp_replace(v, '\m(UNIDADE|LABORATORIO|LAB|INATIVO|INATIVA)\M', ' ', 'g');
  -- Abreviações vistas nas fontes.
  v := regexp_replace(v, '\mADM\M', 'ADMINISTRATIVO', 'g');
  v := regexp_replace(v, '\mHOSP\M', 'HOSPITAL', 'g');
  v := regexp_replace(v, '\mPCLINICA\M', 'POLICLINICA', 'g');
  v := regexp_replace(v, '\mHOMECARE\M', 'HOME CARE', 'g');
  v := regexp_replace(v, '\m(VIDA CARD|VCARD)\M', 'VIDACARD', 'g');
  return nullif(btrim(regexp_replace(v, '\s+', ' ', 'g')), '');
end
$$;

comment on function core.normaliza_nome(text) is
  'Normaliza nome de unidade para comparação entre sistemas.';

-- Chave de grafia de empresa: minúsculo, sem acento, separado por hífen.
create or replace function core.normaliza_grafia(p text)
returns text
language sql immutable parallel safe
set search_path = ''
as $$
  select nullif(btrim(regexp_replace(lower(core.f_unaccent(coalesce(p, ''))), '[^a-z0-9]+', '-', 'g'), '-'), '')
$$;

-- Competência em qualquer formato usado nas fontes ('MM/AAAA', 'AAAA-MM',
-- 'AAAA-MM-DD', 'AAAAMM') para o primeiro dia do mês. Valor inválido vira null.
create or replace function core.normaliza_competencia(p text)
returns date
language plpgsql immutable parallel safe
set search_path = ''
as $$
declare
  v text := btrim(coalesce(p, ''));
  ano int;
  mes int;
begin
  if v ~ '^\d{1,2}/\d{4}$' then
    mes := split_part(v, '/', 1)::int;
    ano := split_part(v, '/', 2)::int;
  elsif v ~ '^\d{4}-\d{1,2}(-\d{1,2})?([ T].*)?$' then
    ano := substr(v, 1, 4)::int;
    mes := split_part(v, '-', 2)::int;
  elsif v ~ '^\d{6}$' then
    ano := left(v, 4)::int;
    mes := right(v, 2)::int;
  else
    return null;
  end if;

  if mes not between 1 and 12 or ano not between 1990 and 2100 then
    return null;
  end if;
  return make_date(ano, mes, 1);
end
$$;

-- Período ------------------------------------------------------------------

create table core.dim_periodo (
  competencia     date primary key check (extract(day from competencia) = 1),
  ano             smallint not null,
  mes             smallint not null check (mes between 1 and 12),
  trimestre       smallint not null,
  semestre        smallint not null,
  competencia_iso text not null unique,   -- 'AAAA-MM'
  competencia_br  text not null unique,   -- 'MM/AAAA'
  inicio          date not null,
  fim             date not null,
  dias_no_mes     smallint not null
);

insert into core.dim_periodo
select d::date,
       extract(year from d),
       extract(month from d),
       extract(quarter from d),
       case when extract(month from d) <= 6 then 1 else 2 end,
       to_char(d, 'YYYY-MM'),
       to_char(d, 'MM/YYYY'),
       d::date,
       (d + interval '1 month - 1 day')::date,
       extract(day from d + interval '1 month - 1 day')
from generate_series(date '2020-01-01', date '2032-12-01', interval '1 month') d;

-- Empresa ------------------------------------------------------------------
-- Três níveis: o grupo, as marcas comerciais e os laboratórios (razão social/CNPJ).

create table core.dim_empresa (
  empresa_id   text primary key check (empresa_id ~ '^[a-z][a-z0-9_]*$'),
  nome         text not null,
  tipo         text not null check (tipo in ('grupo', 'marca', 'laboratorio')),
  marca_id     text references core.dim_empresa (empresa_id),
  razao_social text,
  cnpj         text check (cnpj ~ '^\d{14}$'),
  ativo        boolean not null default true,
  check (tipo = 'laboratorio' or marca_id is null)
);

create table core.empresa_alias (
  grafia     text not null check (grafia = core.normaliza_grafia(grafia)),
  tipo       text not null check (tipo in ('marca', 'laboratorio')),
  empresa_id text not null references core.dim_empresa (empresa_id),
  origem     text,
  primary key (grafia, tipo)
);

comment on table core.empresa_alias is
  'Dicionário de grafias de empresa nas fontes. A mesma grafia pode apontar para uma marca e para um laboratório (ex.: "endocrimeta").';

create or replace function core.resolve_empresa(p_grafia text, p_tipo text default 'laboratorio')
returns text
language sql stable parallel safe
set search_path = ''
as $$
  select a.empresa_id
  from core.empresa_alias a
  where a.grafia = core.normaliza_grafia(p_grafia)
    and a.tipo = p_tipo
$$;

-- Hub e região -------------------------------------------------------------

create table core.dim_hub (
  hub_id text primary key check (hub_id ~ '^[a-z][a-z0-9_]*$'),
  nome   text not null,
  uf     char(2) not null
);

-- Regiões comerciais (fonte: METAS). Populada pela ingestão.
create table core.dim_regiao (
  regiao_id      uuid primary key default gen_random_uuid(),
  nome           text not null,
  fonte          text not null,
  id_na_fonte    text not null,
  ativo          boolean not null default true,
  unique (fonte, id_na_fonte)
);

-- Setor (departamentos que aparecem como "unidade" no Wiki e na Avaliação) -------

create table core.dim_setor (
  setor_id text primary key check (setor_id ~ '^[a-z][a-z0-9_]*$'),
  nome     text not null
);

create table core.setor_alias (
  nome_normalizado text primary key check (nome_normalizado = core.normaliza_nome(nome_normalizado)),
  setor_id         text not null references core.dim_setor (setor_id)
);

alter table core.dim_periodo   enable row level security;
alter table core.dim_empresa   enable row level security;
alter table core.empresa_alias enable row level security;
alter table core.dim_hub       enable row level security;
alter table core.dim_regiao    enable row level security;
alter table core.dim_setor     enable row level security;
alter table core.setor_alias   enable row level security;

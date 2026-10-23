-- Relatório de qualidade do de-para de unidades, por fonte.

create view mart.v_relatorio_casamento
with (security_invoker = true) as
select
  a.fonte,
  count(*)                                                        as total,
  count(*) filter (where a.status in ('automatico', 'confirmado') and a.unidade_id is not null) as casadas_unidade,
  count(*) filter (where a.status in ('automatico', 'confirmado') and a.setor_id is not null)   as casadas_setor,
  count(*) filter (where a.status = 'sugerido')                   as sugeridas,
  count(*) filter (where a.status = 'revisar')                    as a_revisar,
  count(*) filter (where a.metodo = 'sem_par' and a.status <> 'rejeitado') as sem_par,
  count(*) filter (where a.metodo = 'codigo_conflito')            as conflitos_codigo,
  count(*) filter (where a.status = 'rejeitado')                  as rejeitadas,
  round(100.0 * count(*) filter (where a.status in ('automatico', 'confirmado'))
        / nullif(count(*), 0), 1)                                 as pct_casado,
  round(avg(a.confianca) filter (where a.status in ('automatico', 'confirmado', 'sugerido')), 3) as confianca_media,
  max(a.atualizado_em)                                            as atualizado_em
from core.unidade_alias a
where a.fonte <> 'referencia'
group by a.fonte;

comment on view mart.v_relatorio_casamento is
  'Quantas unidades de cada fonte casaram com a unidade mestra, quantas aguardam revisão e a confiança média.';

-- Fila de revisão humana, com os candidatos sugeridos.
create view mart.v_casamento_pendencias
with (security_invoker = true) as
select a.alias_id, a.fonte, a.id_na_fonte, a.nome_na_fonte, a.codigo_na_fonte,
       a.metodo, a.status, a.confianca,
       u.nome as unidade_sugerida,
       core.codigo_da_unidade(a.unidade_id) as codigo_sugerido,
       a.candidatos
from core.unidade_alias a
left join core.dim_unidade u on u.unidade_id = a.unidade_id
where a.status in ('sugerido', 'revisar');

-- Unidades mestras que nenhuma fonte referencia (ou só algumas).
create view mart.v_cobertura_unidade
with (security_invoker = true) as
select u.unidade_id,
       core.codigo_da_unidade(u.unidade_id) as codigo_unilab,
       u.nome, u.tipo, u.situacao,
       coalesce(jsonb_object_agg(a.fonte, a.id_na_fonte) filter (where a.fonte is not null), '{}'::jsonb) as fontes,
       count(a.fonte) as n_fontes
from core.dim_unidade u
left join core.v_unidade_alias_efetivo a on a.unidade_id = u.unidade_id and a.fonte <> 'referencia'
group by u.unidade_id;

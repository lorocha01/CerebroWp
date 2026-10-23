-- Apelidos de referência e unidades fora do Unilab.
--
-- Apelidos: nomes que aparecem com o mesmo código em dois ou mais sistemas
-- (Fase 0), mas que o Unilab escreve de outro jeito. Entram como automáticos
-- (fonte 'referencia') para que as demais fontes casem por nome.

insert into core.dim_unidade (nome, tipo, laboratorio_id, marca_id, hub_id, situacao, classificacao_origem)
values
  ('VENDA DIGITAL - PRIVADO',   'canal_digital', null, null, null, 'ativa', 'metas'),
  ('VENDA DIGITAL - CONVÊNIOS', 'canal_digital', null, null, null, 'ativa', 'metas');

insert into core.unidade_alias (fonte, id_na_fonte, nome_na_fonte, codigo_na_fonte, unidade_id, metodo, confianca, status)
select 'referencia', a.apelido, a.apelido, a.codigo, core.unidade_do_codigo(a.codigo), 'manual', 0.9, 'automatico'
from (values
  ('03', 'HOME CARE LAGES'),          -- METAS, COMPRAS, Ativos, Wiki (Unilab: COLETA MÓVEL LAGES)
  ('43', 'HOME CARE PF'),             -- COMPRAS, Ativos, Wiki
  ('43', 'HOME CARE PASSO FUNDO'),    -- METAS
  ('95', 'HOMECARE ENDO'),            -- COMPRAS, Ativos, Wiki
  ('95', 'HOME CARE PORTO ALEGRE'),   -- METAS
  ('17', 'HNP'),                      -- COMPRAS, Wiki
  ('17', 'HNP - NOVA PETRÓPOLIS'),    -- Ativos
  ('17', 'HOSPITAL NOVA PETROPOLIS'), -- Contas Fixas
  ('29', 'HOSPITAL TEREZA RAMOS'),    -- METAS, Contas Fixas
  ('71', 'CONTE MATRIZ'),             -- METAS, COMPRAS, Ativos, Contas Fixas, Wiki (Unilab: GRAVATAÍ)
  ('72', 'CONTE CACHOEIRINHA'),       -- Contas Fixas, Wiki
  ('72', 'CACHOEIRINHA CONTE'),       -- Ativos
  ('72', 'CACHOEIRINHA CON'),         -- COMPRAS
  ('9E', 'HOSPITAL MUNICIPAL'),       -- COMPRAS, Abertura (Unilab: HBCS)
  ('9E', 'HOSPITAL MUNICIPAL DE PASSO FUNDO'), -- Ativos
  ('56', 'RUBEN BERTHA'),             -- METAS (grafia)
  ('82', 'VITA RIN'),                 -- METAS (grafia)
  ('47', 'GEHTAL')                    -- Contas Fixas (grafia)
) as a(codigo, apelido);

do $$
begin
  if exists (select 1 from core.unidade_alias where fonte = 'referencia' and unidade_id is null) then
    raise exception 'apelido de referência com código inexistente';
  end if;
end
$$;

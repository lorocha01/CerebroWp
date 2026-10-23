-- De-para de unidades com os casos reais encontrados na Fase 0.

create temporary table _u as
select uc.codigo_unilab as codigo, u.unidade_id
from core.unidade_codigo uc join core.dim_unidade u using (unidade_id);

create function pg_temp.uid(p_codigo text) returns uuid language sql as
$$ select unidade_id from _u where codigo = p_codigo $$;

-- Seed ------------------------------------------------------------------------
select teste.igual((select count(*) from core.dim_unidade where tipo <> 'canal_digital'), 114::bigint, '114 postos do Unilab');
select teste.igual((select count(*) from core.dim_unidade where tipo = 'canal_digital'), 2::bigint, 'canais digitais do METAS');
select teste.igual((select count(*) from core.unidade_codigo), 114::bigint, 'um código por posto');
select teste.igual((select count(*) from core.unidade_alias where fonte = 'referencia' and status = 'automatico'), 18::bigint, 'apelidos de referência');
select teste.verdade(not exists (select 1 from core.dim_unidade where marca_id is distinct from
  (select marca_id from core.dim_empresa e where e.empresa_id = laboratorio_id)), 'marca coerente com o laboratório');
select teste.igual((select laboratorio_id from core.dim_unidade where unidade_id = pg_temp.uid('9K')), 'lab_santa_helena', '9K é Santa Helena');
select teste.igual((select laboratorio_id from core.dim_unidade where unidade_id = pg_temp.uid('14')), 'lab_pacheco', '14 (Santa Helena de Lages) é Pacheco');

-- Código ----------------------------------------------------------------------
select teste.igual((select metodo from core.casar_unidade('01', 'UNIDADE CENTRO LAGES', '2026-10-23')), 'codigo', 'METAS 01');
select teste.igual((select unidade_id from core.casar_unidade('01', 'UNIDADE CENTRO LAGES', '2026-10-23')), pg_temp.uid('01'), 'METAS 01 aponta para 01');
select teste.igual((select metodo from core.casar_unidade('05', 'UNIDADE CLINICA HIGIA', '2026-10-23')), 'codigo', 'METAS 05 com nome mais longo');
select teste.igual((select metodo from core.casar_unidade('29', 'HMTR - TEREZA RAMOS', '2026-10-23')), 'codigo', 'Ativos 29');
select teste.igual((select metodo from core.casar_unidade('07', null, '2026-10-23')), 'codigo', 'código sem nome');

-- Código que existe mas com nome de outra coisa: sugere, não confirma.
select teste.igual((select metodo from core.casar_unidade('96', 'APOIO PASTEUR', '2026-10-23')), 'codigo_conflito', 'Ativos 96 APOIO PASTEUR');
select teste.igual((select metodo from core.casar_unidade('87', 'HOMECARE ENDO 2', '2026-10-23')), 'codigo_conflito', 'Ativos 87 HOMECARE ENDO 2');

-- Vigência: 87 só vale a partir de 20/07/2026; 89 fechou em 30/04/2026.
select teste.igual((select metodo from core.casar_unidade('87', 'ESTANCIA VELHA', '2026-08-01')), 'codigo', '87 depois da abertura');
select teste.verdade((select metodo from core.casar_unidade('87', 'ESTANCIA VELHA', '2026-03-01')) <> 'codigo', '87 antes da abertura não casa por código');
select teste.igual((select metodo from core.casar_unidade('89', 'CANOAS MEDICAL', '2026-03-01')), 'codigo', '89 antes do fechamento');
select teste.verdade((select metodo from core.casar_unidade('89', 'CANOAS MEDICAL', '2026-06-01')) <> 'codigo', '89 depois do fechamento');

-- Código desconhecido cai para o nome.
select teste.igual((select metodo from core.casar_unidade('1', 'Laboratório Santa Helena - Viamópolis ', '2026-10-23')), 'nome_aproximado', 'COMPRAS "1"');
select teste.igual((select unidade_id from core.casar_unidade('1', 'Laboratório Santa Helena - Viamópolis ', '2026-10-23')), pg_temp.uid('9K'), 'COMPRAS "1" sugere 9K');
select teste.igual((select metodo from core.casar_unidade('UNI-01', 'Matriz', '2026-10-23')), 'sem_par', 'COMPRAS UNI-01 de teste');

-- Nome ------------------------------------------------------------------------
select teste.igual((select metodo from core.casar_unidade(null, 'SANTA HELENA', '2026-10-23')), 'nome_exato', 'Contas Fixas SANTA HELENA');
select teste.igual((select unidade_id from core.casar_unidade(null, 'SANTA HELENA', '2026-10-23')), pg_temp.uid('14'), 'SANTA HELENA é o 14 de Lages');
select teste.igual((select unidade_id from core.casar_unidade(null, 'MOINHOS DE VENTO', '2026-10-23')), pg_temp.uid('60'), 'Contas Fixas MOINHOS DE VENTO');
select teste.igual((select unidade_id from core.casar_unidade(null, 'SÃO LEOPOLDO', '2026-10-23')), pg_temp.uid('96'), 'Ativos SÃO LEOPOLDO sem número');
select teste.igual((select unidade_id from core.casar_unidade(null, 'Santa Helena - Salgado Filho', '2026-10-23')), pg_temp.uid('9H'), 'Wiki Santa Helena Salgado Filho');
select teste.igual((select metodo from core.casar_unidade(null, 'xyzw qualquer', '2026-10-23')), 'sem_par', 'nome sem semelhança');

-- Setor -----------------------------------------------------------------------
select teste.igual((select setor_id from core.casar_unidade(null, 'DIREÇÃO WP', '2026-10-23')), 'direcao', 'Wiki DIREÇÃO WP');
select teste.igual((select setor_id from core.casar_unidade(null, 'Recursos Humanos', '2026-10-23')), 'rh', 'Avaliação Recursos Humanos');
select teste.igual((select metodo from core.casar_unidade(null, 'COMPRAS', '2026-10-23')), 'setor', 'Wiki COMPRAS é setor');

-- Cadastro sem data (unidade como existe na fonte) -----------------------------
select teste.igual((select metodo from core.casar_unidade('89', 'CANOAS MEDICAL')), 'codigo', 'unidade fechada casa no cadastro');
select teste.igual((select metodo from core.casar_unidade('52', 'ADM ENDO')), 'codigo', 'abreviação ADM');
select teste.igual((select metodo from core.casar_unidade('03', 'UNIDADE HOME CARE LAGES')), 'codigo', 'apelido de referência HOME CARE');
select teste.igual((select metodo from core.casar_unidade('71', 'CONTE MATRIZ')), 'codigo', 'apelido CONTE MATRIZ');
select teste.igual((select unidade_id from core.casar_unidade(null, 'HNP')), pg_temp.uid('17'), 'Wiki HNP pelo apelido');
select teste.igual((select unidade_id from core.casar_unidade(null, 'VCARD URUGUAIANA')), pg_temp.uid('40'), 'VCARD = VIDA CARD');
select teste.igual((select metodo from core.casar_unidade(null, 'CACHOEIRINHA LAB SANTA HELENA')), 'nome_exato', 'mesmas palavras em outra ordem');
select teste.igual((select unidade_id from core.casar_unidade(null, 'CACHOEIRINHA LAB SANTA HELENA')), pg_temp.uid('9I'), 'Santa Helena Cachoeirinha é 9I');
select teste.igual((select metodo from core.casar_unidade(null, 'VENDA DIGITAL - PRIVADO')), 'nome_exato', 'canal digital');
select teste.igual((select metodo from core.casar_unidade(null, 'SANTA HELENA VIAMÃO')), 'ambiguo', 'Viamão tem dois postos (9J e 9K)');
select teste.igual((select metodo from core.casar_unidade('87', 'HOMECARE ENDO 2')), 'codigo_conflito', '87 no cadastro usa a vigência mais recente');

-- Registro e revisão -----------------------------------------------------------
select core.registrar_alias('compras', 'u-55', 'ESTOQUE CENTRAL', '55');
select teste.igual((select status from core.unidade_alias where fonte = 'compras' and id_na_fonte = 'u-55'), 'revisar', 'código com nome diferente vai para revisão');
select teste.igual((select unidade_id from core.unidade_alias where fonte = 'compras' and id_na_fonte = 'u-55'), pg_temp.uid('55'), 'sugestão pelo código');
select teste.verdade(not exists (select 1 from core.v_unidade_alias_efetivo where fonte = 'compras' and id_na_fonte = 'u-55'), 'em revisão não entra nos fatos');

select core.revisar_alias((select alias_id from core.unidade_alias where fonte = 'compras' and id_na_fonte = 'u-55'), 'confirmado', 'teste');
select teste.verdade(exists (select 1 from core.v_unidade_alias_efetivo where fonte = 'compras' and id_na_fonte = 'u-55'), 'confirmado entra nos fatos');
select teste.igual((select count(*) from audit.evento where acao = 'revisar_alias'), 1::bigint, 'revisão auditada');

-- Depois de confirmado, o nome passa a valer para outras fontes.
select teste.igual((select metodo from core.casar_unidade(null, 'Estoque Central')), 'nome_exato', 'outra fonte casa pelo nome confirmado');
select teste.igual((select unidade_id from core.casar_unidade(null, 'Estoque Central')), pg_temp.uid('55'), 'e aponta para o 55');

-- Reingestão não desfaz decisão humana.
select core.registrar_alias('compras', 'u-55', 'ESTOQUE CENTRAL', '55');
select teste.igual((select status from core.unidade_alias where fonte = 'compras' and id_na_fonte = 'u-55'), 'confirmado', 'reingestão preserva confirmado');

select core.registrar_alias('ativos', 'loc-96', 'APOIO PASTEUR', '96', '2026-10-23');
select core.revisar_alias((select alias_id from core.unidade_alias where fonte = 'ativos' and id_na_fonte = 'loc-96'), 'rejeitado', 'teste');
select core.registrar_alias('ativos', 'loc-96', 'APOIO PASTEUR', '96', '2026-10-23');
select teste.igual((select status from core.unidade_alias where fonte = 'ativos' and id_na_fonte = 'loc-96'), 'rejeitado', 'reingestão preserva rejeitado');
select teste.igual((select unidade_id from core.unidade_alias where fonte = 'ativos' and id_na_fonte = 'loc-96'), null::uuid, 'rejeitado fica sem unidade');

-- Relatório de casamento
select core.registrar_alias('metas', 'm-01', 'UNIDADE CENTRO LAGES', '01', '2026-10-23');
select core.registrar_alias('metas', 'm-x', 'QUALYS', null);
select teste.igual((select total from mart.v_relatorio_casamento where fonte = 'metas'), 2::bigint, 'relatório: total');
select teste.igual((select casadas_unidade from mart.v_relatorio_casamento where fonte = 'metas'), 1::bigint, 'relatório: casadas');
select teste.igual((select pct_casado from mart.v_relatorio_casamento where fonte = 'metas'), 50.0, 'relatório: percentual');

-- Sobreposição de vigência do mesmo código é proibida.
do $$
begin
  insert into core.unidade_codigo (codigo_unilab, unidade_id, vigencia)
  values ('01', (select unidade_id from core.unidade_codigo where codigo_unilab = '96'), daterange('2026-01-01', null));
  raise exception 'FALHOU: aceitou vigência sobreposta';
exception when exclusion_violation then null;
end
$$;

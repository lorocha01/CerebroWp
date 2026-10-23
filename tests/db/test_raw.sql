-- Versionamento da camada raw.

select teste.igual(raw.registrar('metas', 'units', 'u1', '{"code": "01", "name": "UNIDADE CENTRO LAGES"}'), true, 'primeira versão é nova');
select teste.igual(raw.registrar('metas', 'units', 'u1', '{"name": "UNIDADE CENTRO LAGES", "code": "01"}'), false, 'mesmo conteúdo em outra ordem não gera versão');
select teste.igual(raw.registrar('metas', 'units', 'u1', '{"code": "01", "name": "CENTRO LAGES"}'), true, 'mudança gera versão');
select teste.igual((select count(*) from raw.registro where chave_fonte = 'u1'), 2::bigint, 'duas versões guardadas');
select teste.igual((select count(*) from raw.registro where chave_fonte = 'u1' and vigente), 1::bigint, 'uma versão vigente');
select teste.igual((select payload->>'name' from raw.registro where chave_fonte = 'u1' and vigente), 'CENTRO LAGES', 'vigente é a mais recente');

-- Voltar ao conteúdo anterior reativa a versão antiga sem duplicar.
select teste.igual(raw.registrar('metas', 'units', 'u1', '{"code": "01", "name": "UNIDADE CENTRO LAGES"}'), true, 'volta ao conteúdo anterior');
select teste.igual((select count(*) from raw.registro where chave_fonte = 'u1'), 2::bigint, 'sem linha duplicada');
select teste.igual((select payload->>'name' from raw.registro where chave_fonte = 'u1' and vigente), 'UNIDADE CENTRO LAGES', 'versão antiga reativada');

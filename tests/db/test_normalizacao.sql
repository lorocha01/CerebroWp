-- Normalização de nome, competência e empresa.

select teste.igual(core.normaliza_nome('SÃO CRISTÓVÃO(Widal) CRBM-5:2018-0114-01'), 'SAO CRISTOVAO', 'marcador e CRBM colados');
select teste.igual(core.normaliza_nome('UNIDADE CENTRO LAGES'), 'CENTRO LAGES', 'prefixo UNIDADE (METAS)');
select teste.igual(core.normaliza_nome('RUBEM BERTA(Endocrimeta)CRBM5:2013006603'), 'RUBEM BERTA', 'CRBM sem hífen');
select teste.igual(core.normaliza_nome('ADMINISTRATIVO ENDO - CRF/RS: 4173'), 'ADMINISTRATIVO ENDO', 'CRF com hífen antes');
select teste.igual(core.normaliza_nome('NOVA PETRÓPOLIS (Widal) CRBIO: 12117-03'), 'NOVA PETROPOLIS', 'CRBIO');
select teste.igual(core.normaliza_nome('CANOAS MEDICAL (FECHADO)'), 'CANOAS MEDICAL', 'marcador de fechado (Ativos)');
select teste.igual(core.normaliza_nome('HSP LAGOA  - INATIVO'), 'HSP LAGOA', 'sufixo INATIVO');
select teste.igual(core.normaliza_nome('Laboratório Santa Helena - Viamópolis '), 'SANTA HELENA VIAMOPOLIS', 'prefixo Laboratório (COMPRAS)');
select teste.igual(core.normaliza_nome('HOSP. DA CRIANÇA'), 'HOSPITAL DA CRIANCA', 'pontuação e abreviação HOSP');
select teste.igual(core.normaliza_nome('ADM ENDO'), 'ADMINISTRATIVO ENDO', 'abreviação ADM');
select teste.igual(core.normaliza_nome('PCLINICA MILITAR'), 'POLICLINICA MILITAR', 'abreviação PCLINICA');
select teste.igual(core.normaliza_nome('VCARD URUGUAIANA'), core.normaliza_nome('VIDA CARD URUGUAIANA'), 'VCARD e VIDA CARD');
select teste.igual(core.normaliza_nome('HOMECARE ENDO'), 'HOME CARE ENDO', 'HOMECARE');
select teste.igual(core.normaliza_nome('ADMINISTRADORA'), 'ADMINISTRADORA', 'ADM só como palavra inteira');
select teste.igual(core.normaliza_nome('   '), null::text, 'vazio vira null');
select teste.igual(core.normaliza_nome(null), null::text, 'null continua null');

select teste.igual(core.normaliza_competencia('09/2026'), date '2026-09-01', 'MM/AAAA (DRE)');
select teste.igual(core.normaliza_competencia('9/2026'), date '2026-09-01', 'M/AAAA');
select teste.igual(core.normaliza_competencia('2026-09'), date '2026-09-01', 'AAAA-MM');
select teste.igual(core.normaliza_competencia('2026-9'), date '2026-09-01', 'AAAA-M');
select teste.igual(core.normaliza_competencia('2026-09-15'), date '2026-09-01', 'data completa');
select teste.igual(core.normaliza_competencia('2026-10-01T03:00:00Z'), date '2026-10-01', 'timestamp ISO');
select teste.igual(core.normaliza_competencia('202609'), date '2026-09-01', 'AAAAMM');
select teste.igual(core.normaliza_competencia('13/2026'), null::date, 'mês inválido');
select teste.igual(core.normaliza_competencia('abc'), null::date, 'texto inválido');
select teste.igual(core.normaliza_competencia(null), null::date, 'null');

select teste.igual((select competencia_br from core.dim_periodo where competencia = '2026-09-01'), '09/2026', 'dim_periodo formato BR');
select teste.igual((select competencia_iso from core.dim_periodo where competencia = '2026-09-01'), '2026-09', 'dim_periodo formato ISO');
select teste.igual((select dias_no_mes from core.dim_periodo where competencia = '2028-02-01'), 29::smallint, 'ano bissexto');

select teste.igual(core.resolve_empresa('endo'), 'lab_endocrimeta', 'endo (Conciliação)');
select teste.igual(core.resolve_empresa('ENDO'), 'lab_endocrimeta', 'ENDO (Contas Fixas)');
select teste.igual(core.resolve_empresa('Endocrimeta', 'marca'), 'endocrimeta', 'marca do e-commerce');
select teste.igual(core.resolve_empresa('widal-pacheco', 'marca'), 'widal_pacheco', 'widal-pacheco');
select teste.igual(core.resolve_empresa('Widal Pacheco', 'marca'), 'widal_pacheco', 'Widal Pacheco com espaço');
select teste.igual(core.resolve_empresa('widal'), 'lab_widal', 'widal laboratório');
select teste.igual(core.resolve_empresa('widal', 'marca'), 'widal_pacheco', 'widal marca');
select teste.igual(core.resolve_empresa('PACHECO'), 'lab_pacheco', 'PACHECO');
select teste.igual(core.resolve_empresa('conte'), 'lab_conte', 'conte');
select teste.igual(core.resolve_empresa('Santa Helena', 'marca'), 'santa_helena', 'Santa Helena');
select teste.igual(core.resolve_empresa('Santa Helenea'), 'lab_santa_helena', 'grafia errada do COMPRAS');
select teste.igual(core.resolve_empresa('xyz'), null::text, 'grafia desconhecida');

-- Unidades mestras a partir da lista de postos do Unilab (DRE, competência 09/2026).
--
-- Provisório até a validação com a lista oficial do grupo (validado = false):
--   * laboratório e marca vêm do marcador no nome do Unilab ou, sem ele, do hub;
--   * 71, 72 e 73 estão como Conte pelo agrupamento do Contas Fixas (no Unilab aparecem como Endocrimeta);
--   * vigência dos códigos usa abertura/fechamento do DRE (unit_config) quando existe.
-- Registros profissionais (CRBM/CRF/CRBIO) foram retirados do nome.

create temporary table _seed_unidade (
  codigo text, nome text, tipo text, laboratorio_id text, marca_id text, hub_id text,
  situacao text, classificacao_origem text, vigente_de date, vigente_ate date
);

insert into _seed_unidade values
  ('01', 'CENTRO LAGES', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', '1946-01-01', null),
  ('02', 'BENTO', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('03', 'COLETA MÓVEL LAGES', 'coleta_movel', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'regra_hub', null, null),
  ('04', 'COXILHA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', '2023-02-28', null),
  ('05', 'HIGIA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('06', 'COLUMBIA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('07', 'SÃO CRISTÓVÃO', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('08', 'PAISSANDU', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('09', 'PONTÃO', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('10', 'SOLEDADE', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('11', 'LAGOA VERMELHA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('12', 'HSP LAGOA', 'hospital', null, null, null, 'inativa', 'indefinido', null, null),
  ('13', 'GUARUJÁ', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('14', 'SANTA HELENA', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('15', 'BOCAINA DO SUL', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('16', 'URUPEMA', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('17', 'NOVA PETRÓPOLIS', 'hospital', 'lab_widal', 'widal_pacheco', 'nova_petropolis', 'ativa', 'nome_unilab', null, null),
  ('18', 'BRASIL', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', '2024-05-01', null),
  ('19', 'ESEGT URUGUAIANA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('20', 'ADMINISTRATIVO WP', 'administrativo', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('21', 'VERA CRUZ', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('22', 'HNP Urgência', 'hospital', 'lab_widal', 'widal_pacheco', 'nova_petropolis', 'ativa', 'nome_unilab', null, null),
  ('23', 'GENESIS', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2025-04-30', null),
  ('24', 'PAINEL', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('25', 'CAPÃO ALTO', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('27', 'VIDACARD ITAQUI', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'inativa', 'regra_hub', null, null),
  ('28', 'TIO HUGO', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2024-09-30', null),
  ('29', 'HMTR', 'hospital', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('30', 'VIDA CARD BAGÉ', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2025-01-31', null),
  ('31', 'TAPEJARA', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('32', 'CORAL', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('33', 'CAMPO BELO', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('34', 'VIDA CARD ALEGRETE', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('35', 'AMBROSIO', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('36', 'SANTA MONICA', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('37', 'CENTENÁRIO', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('38', 'VIDA CARD LAJEADO', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('39', 'VIDA CARD ERECHIM', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('40', 'VIDA CARD URUGUAIANA', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('41', 'VIDA CARD IBIRUBA', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('42', 'HDWC -IBIRAMA', 'hospital', 'lab_pacheco', 'widal_pacheco', 'ibirama', 'ativa', 'nome_unilab', null, null),
  ('43', 'COLETA MÓVEL PF', 'coleta_movel', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('44', 'VIDA CARD BENTO GONÇALVES', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2023-07-31', null),
  ('45', 'VIDA CARD PELOTAS', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('46', 'CLINICA ANGELS', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('47', 'GETHAL', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('48', 'CEDIL', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', '2025-05-01', null),
  ('49', 'PARAÍ', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', null, null),
  ('50', 'VIDACARD SANTANA DO LIVRAMENTO', 'clinica_parceira', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'inativa', 'regra_hub', null, null),
  ('51', 'CENTRO CLÍNICO ASSISENSE', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('52', 'ADMINISTRATIVO ENDO', 'administrativo', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('53', 'CENTRO DOM', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('54', 'PRODUÇÃO LAGES', 'producao', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', null, null),
  ('55', 'SUPRIMENTOS LAGES', 'administrativo', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'regra_hub', null, null),
  ('56', 'RUBEM BERTA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('57', 'PETROPOLIS - WP', 'posto', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2025-07-01', null),
  ('58', 'NILO PEÇANHA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('59', 'CENTRO SUS', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('60', 'MOINHOS', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('61', 'MENINO DEUS', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('62', 'AUXILIADORA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('63', 'OTTO I', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('64', 'OTTO II', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('65', 'RESTINGA II', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('66', 'MEDPLEX', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('67', 'POLICLINICA ALVORADA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('68', 'RESTINGA I', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('69', 'CANOAS', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', '2025-03-31', null),
  ('70', 'CACHOEIRINHA PRÓ SAÚDE', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('71', 'GRAVATAÍ', 'posto', 'lab_conte', 'endocrimeta', 'porto_alegre', 'ativa', 'contas_fixas_grupo', null, null),
  ('72', 'CACHOEIRINHA', 'posto', 'lab_conte', 'endocrimeta', 'porto_alegre', 'ativa', 'contas_fixas_grupo', null, null),
  ('73', 'MILLENARIUM', 'posto', 'lab_conte', 'endocrimeta', 'porto_alegre', 'ativa', 'contas_fixas_grupo', null, null),
  ('74', 'REGULARIZE - CANOAS', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('75', 'PRODUÇÃO ENDOCRIMETA', 'producao', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('76', 'PRO AMBIENTE', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('77', 'REGULARIZE - PORTO ALEGRE', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('78', 'TOXILAB', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('79', 'SANTO ANTONIO', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('80', 'IVOTI', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('81', 'BELEM NOVO', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('82', 'VITARIM', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('83', 'HOSPITAL FEMINA', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('84', 'HOSP. DA CRIANÇA', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('85', 'HOSP. CONCEIÇÃO', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('86', 'CIPO HOSP C. REDENTOR', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('87', 'ESTANCIA VELHA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', '2026-07-20', null),
  ('88', 'HOSPITAL MILITAR', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('89', 'CANOAS MEDICAL', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'inativa', 'regra_hub', '2023-09-30', '2026-05-01'),
  ('90', 'GENTE SAÚDE', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('91', 'HABITAÇÃO', 'posto', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'nome_unilab', '2023-10-31', null),
  ('92', 'PROTÁSIO ALVES', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', '2026-01-22', null),
  ('93', 'POLICLINICA MILITAR', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('94', 'RCZ', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('95', 'COLETA MÓVEL ENDOCRIMETA', 'coleta_movel', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('96', 'SAO LEOPOLDO - ENDO', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', '2026-06-02', null),
  ('97', 'MED DIAGNÓSTICA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('98', 'SARANDI', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('99', 'LOMBA DO PINHEIRO', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null),
  ('9B', 'ADMINISTRATIVO PACHECO', 'administrativo', 'lab_pacheco', 'widal_pacheco', 'lages', 'ativa', 'regra_hub', null, null),
  ('9C', 'PRODUÇÃO WIDAL', 'producao', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', null, null),
  ('9D', 'SAPUCAIA - ENDO', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', '2026-08-03', null),
  ('9E', 'HBCS - CENTRO DIAGNOSTICOS', 'hospital', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'nome_unilab', '2026-07-01', null),
  ('9F', 'HBCS - PRONTO ATENDIMENTO E INTERNADOS', 'hospital', 'lab_widal', 'widal_pacheco', 'passo_fundo', 'ativa', 'regra_hub', '2026-07-01', null),
  ('9G', 'SANTA HELENA MATRIZ - SANTANA', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9H', 'SANTA HELENA CENTRO - SEN. SALGADO FILHO', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9I', 'SANTA HELENA - CACHOEIRINHA', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9J', 'SANTA HELENA - VIAMÃO - SANTA ISABEL', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9K', 'SANTA HELENA - VIAMÃO - VIAMÓPOLIS', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9L', 'SANTA HELENA - GRAVATAÍ - CENTRO', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9M', 'SANTA HELENA - GRAVATAÍ - VILA BRANCA', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9N', 'SANTA HELENA - SANTO ANTÔNIO DA PATRULHA', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', '2026-10-01', null),
  ('9O', 'WENCESLAU - ENDOCRIMETA', 'posto', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', '2026-10-01', null),
  ('9P', 'SANTA HELENA - ITAPUÃ VIAMAO', 'posto', 'lab_santa_helena', 'santa_helena', 'porto_alegre', 'ativa', 'nome_unilab', null, null),
  ('9Q', 'HOSPITAL DOCTOR CLIN POA', 'hospital', 'lab_endocrimeta', 'endocrimeta', 'porto_alegre', 'ativa', 'regra_hub', null, null);

with novas as (
  insert into core.dim_unidade (nome, tipo, laboratorio_id, marca_id, hub_id, situacao, classificacao_origem)
  select nome, tipo, laboratorio_id, marca_id, hub_id, situacao, classificacao_origem
  from _seed_unidade
  order by codigo
  returning unidade_id, nome
)
insert into core.unidade_codigo (codigo_unilab, unidade_id, vigencia, origem)
select s.codigo, n.unidade_id, daterange(s.vigente_de, s.vigente_ate), 'unilab_dre_2026_09'
from _seed_unidade s
join novas n on n.nome = s.nome;

drop table _seed_unidade;

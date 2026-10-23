-- Dados de referência: empresas, grafias, hubs, setores e catálogo de fontes.
-- CNPJ e razão social completos entram pela ingestão do COMPRAS (billing_entities).

insert into core.dim_empresa (empresa_id, nome, tipo, marca_id) values
  ('grupo_wp',         'Grupo WP',               'grupo',       null),
  ('endocrimeta',      'Endocrimeta',            'marca',       null),
  ('widal_pacheco',    'Widal Pacheco',          'marca',       null),
  ('santa_helena',     'Santa Helena',           'marca',       null),
  ('lab_endocrimeta',  'Laboratório Endocrimeta','laboratorio', 'endocrimeta'),
  ('lab_conte',        'Laboratório Conte',      'laboratorio', 'endocrimeta'),
  ('lab_widal',        'Laboratório Widal',      'laboratorio', 'widal_pacheco'),
  ('lab_pacheco',      'Laboratório Pacheco',    'laboratorio', 'widal_pacheco'),
  ('lab_santa_helena', 'Laboratório Santa Helena','laboratorio','santa_helena');

-- Grafias encontradas nas fontes (Fase 0).
insert into core.empresa_alias (grafia, tipo, empresa_id, origem) values
  ('endocrimeta',    'marca',       'endocrimeta',      'ecommerce.units.brand'),
  ('widal-pacheco',  'marca',       'widal_pacheco',    'ecommerce.units.brand'),
  ('widal',          'marca',       'widal_pacheco',    'unidades-publicas'),
  ('santa-helena',   'marca',       'santa_helena',     'ecommerce'),
  ('endo',           'laboratorio', 'lab_endocrimeta',  'concilia/contas_fixas'),
  ('endocrimeta',    'laboratorio', 'lab_endocrimeta',  'apoios/dre'),
  ('conte',          'laboratorio', 'lab_conte',        'concilia/contas_fixas'),
  ('widal',          'laboratorio', 'lab_widal',        'concilia/contas_fixas/dre'),
  ('pacheco',        'laboratorio', 'lab_pacheco',      'apoios/contas_fixas/dre'),
  ('santa-helena',   'laboratorio', 'lab_santa_helena', 'compras'),
  ('santa-helenea',  'laboratorio', 'lab_santa_helena', 'compras.units.region (grafia errada)');

insert into core.dim_hub (hub_id, nome, uf) values
  ('porto_alegre',    'Porto Alegre',    'RS'),
  ('passo_fundo',     'Passo Fundo',     'RS'),
  ('nova_petropolis', 'Nova Petrópolis', 'RS'),
  ('lages',           'Lages',           'SC'),
  ('ibirama',         'Ibirama',         'SC');

insert into core.dim_setor (setor_id, nome) values
  ('direcao',       'Direção'),
  ('ti',            'Tecnologia da Informação'),
  ('rh',            'Recursos Humanos'),
  ('compras',       'Compras'),
  ('suprimentos',   'Suprimentos'),
  ('financeiro',    'Financeiro'),
  ('faturamento',   'Faturamento'),
  ('contabilidade', 'Contabilidade'),
  ('marketing',     'Marketing'),
  ('comercial',     'Comercial'),
  ('qualidade',     'Qualidade'),
  ('area_tecnica',  'Área Técnica'),
  ('atendimento',   'Atendimento e Informações'),
  ('triagem',       'Triagem');

-- Nomes de departamento vistos no Wiki e na Avaliação.
insert into core.setor_alias (nome_normalizado, setor_id) values
  ('DIRECAO WP',        'direcao'),
  ('DIRECAO ENDO',      'direcao'),
  ('TI',                'ti'),
  ('SETOR TI',          'ti'),
  ('TECNOLOGIA',        'ti'),
  ('RH',                'rh'),
  ('RECURSOS HUMANOS',  'rh'),
  ('COMPRAS',           'compras'),
  ('SUPRIMENTOS',       'suprimentos'),
  ('FINANCEIRO',        'financeiro'),
  ('FATURAMENTO',       'faturamento'),
  ('CONTABILIDADE',     'contabilidade'),
  ('MARKETING',         'marketing'),
  ('COMERCIAL',         'comercial'),
  ('QUALIDADE',         'qualidade'),
  ('AREA TECNICA ENDO', 'area_tecnica'),
  ('INFORMACOES',       'atendimento'),
  ('TRIAGEM',           'triagem');

-- Inventário validado na Fase 0 (refs são identificadores públicos de projeto).
insert into raw.fonte (fonte_id, nome, projeto_ref, acesso, fase, observacao) values
  ('metas',          'METAS - GRUPOWP',                  'tldtynfxwmqirvpsmefw', 'api_existente',  1, 'postos-faturamento (2026+) e cerebro-export a criar'),
  ('ativos',         'Gestão de Ativos',                 'njgbhoyzfjwlhodvagyr', 'cerebro_export', 1, 'assets-api mistura leitura e escrita na mesma chave'),
  ('wiki',           'Wiki + Suporte',                   'mszdgutxihjenmsllyxa', 'cerebro_export', 1, 'APIs existentes sem unidade ou com dado pessoal'),
  ('ecom_endo',      'Endocrimeta e-commerce',           'ansgycgsjtlntqhiphep', 'publica',        1, 'unidades-publicas; pedidos agregados na fase 4'),
  ('ecom_widal',     'Widal Pacheco e-commerce',         'biagtdlnsjpfccjinfbb', 'pendente',       4, null),
  ('ecom_sh',        'Santa Helena',                     'lamavmracbpjzytzuioy', 'pendente',       4, null),
  ('dre',            'DRE VERSÃO FINAL',                 'nevoriyifpbzuuadowfw', 'cerebro_export', 2, 'lista de postos do Unilab em dre_months.data.units'),
  ('compras',        'COMPRAS WP',                       'vwvxrmggsqlcbahvigge', 'cerebro_export', 2, null),
  ('contas_fixas',   'CONTAS FIXAS',                     'vfrrgxdvsszxsretzort', 'cerebro_export', 2, null),
  ('concilia',       'CONCILIA FATURAMENTO',             'bwflzzpbsogpjxmcxfwa', 'cerebro_export', 2, 'somente agregados: lancamentos tem nome de paciente'),
  ('apoios',         'CONCILIAÇÃO DE APOIOS',            'kolophdgbhnzbgzanszr', 'cerebro_export', 2, 'somente agregados: itens têm nome de paciente'),
  ('ciq',            'CIQ Insights',                     'xeobnnnwdyvgynjlqvir', 'cerebro_export', 3, null),
  ('abertura',       'Abertura de Unidades',             'tmnzvarrbrtcvlilouze', 'cerebro_export', 3, null),
  ('vagas',          'VAGAS GRUPO WP',                   'tmiwlammirdvtmjyvdce', 'cerebro_export', 4, 'somente agregados'),
  ('avaliacao',      'Avaliação de desempenho',          'rdngauuhbnldrdbzfngz', 'cerebro_export', 4, 'somente agregados'),
  ('juridico',       'JURIDICO',                         'cfthgxvwtwguryamlcdx', 'pendente',       null, 'banco não gerenciado pelo Lovable'),
  ('pdv',            'PDV WP',                           'uouodbbbfvthniuttjcx', 'pendente',       null, null),
  ('mundo_wp',       'MUNDO WP: Our Systems',            'zmtdhwotwwpckinrwmdc', 'pendente',       3, 'interface do Cérebro'),
  ('plataforma_rh',  'Plataforma RH',                    'sstfjnlxwuooknchniov', 'fora_do_escopo', null, 'férias e aniversariantes: dado pessoal'),
  ('impacto_social', 'Impacto Social Form',              'zjnyfvkbnndpzdcegutc', 'fora_do_escopo', null, 'dado sensível');

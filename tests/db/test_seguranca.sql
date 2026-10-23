-- RLS ligado em todas as tabelas do Cérebro e nenhum acesso para anon/authenticated.

select teste.igual(
  (select string_agg(n.nspname || '.' || c.relname, ', ')
   from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname in ('raw', 'core', 'mart', 'audit')
     and c.relkind in ('r', 'p')
     and not c.relrowsecurity),
  null::text,
  'tabelas sem RLS');

select teste.igual(
  (select string_agg(table_schema || '.' || table_name || ':' || grantee, ', ')
   from information_schema.role_table_grants
   where table_schema in ('raw', 'core', 'mart', 'audit')
     and grantee in ('anon', 'authenticated', 'PUBLIC')),
  null::text,
  'privilégio de tabela para anon/authenticated/public');

select teste.verdade(not has_schema_privilege('anon', 'core', 'usage'), 'anon sem uso do schema core');
select teste.verdade(not has_schema_privilege('authenticated', 'mart', 'usage'), 'authenticated sem uso do schema mart');
select teste.verdade(has_schema_privilege('service_role', 'core', 'usage'), 'service_role usa core');
select teste.verdade(has_table_privilege('service_role', 'core.dim_unidade', 'select'), 'service_role lê dim_unidade');

-- Nenhuma política permissiva (USING true) em tabelas do Cérebro.
select teste.igual(
  (select count(*) from pg_policies
   where schemaname in ('raw', 'core', 'mart', 'audit') and (qual = 'true' or with_check = 'true')),
  0::bigint,
  'política com USING true');

-- Funções do Cérebro com search_path fixo.
select teste.igual(
  (select string_agg(p.proname, ', ')
   from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname in ('raw', 'core', 'mart', 'audit')
     and not exists (select 1 from unnest(coalesce(p.proconfig, '{}')) c where c like 'search_path=%')),
  null::text,
  'funções sem search_path fixo');

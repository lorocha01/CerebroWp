-- Fundação do Cérebro: extensões, schemas e privilégios.
--
-- Camadas:
--   raw   cópia versionada do que cada fonte devolve (já filtrado pela allowlist da fonte)
--   core  dimensões mestras e tabelas de de-para
--   mart  fatos e visões prontos para consumo
--   audit registro de quem fez o quê no Cérebro
--
-- Nenhum desses schemas é exposto a anon/authenticated. O acesso de leitura do
-- portal virá por funções específicas (Fase 3), com RLS por papel.

create schema if not exists extensions;
create extension if not exists unaccent with schema extensions;
create extension if not exists pg_trgm with schema extensions;
create extension if not exists btree_gist with schema extensions;
create extension if not exists pgcrypto with schema extensions;

create schema if not exists raw;
create schema if not exists core;
create schema if not exists mart;
create schema if not exists audit;

comment on schema raw is 'Cópia fiel e versionada das fontes (somente colunas autorizadas).';
comment on schema core is 'Dimensões mestras (unidade, empresa, período, setor) e de-para.';
comment on schema mart is 'Fatos analíticos e relatórios prontos para consumo.';
comment on schema audit is 'Trilhas de auditoria do Cérebro.';

revoke all on schema raw, core, mart, audit from public;
revoke all on schema raw, core, mart, audit from anon, authenticated;
grant usage on schema raw, core, mart, audit to service_role;

alter default privileges in schema raw, core, mart, audit revoke all on tables from public, anon, authenticated;
alter default privileges in schema raw, core, mart, audit revoke all on sequences from public, anon, authenticated;
alter default privileges in schema raw, core, mart, audit revoke execute on functions from public, anon, authenticated;
alter default privileges in schema raw, core, mart, audit grant all on tables to service_role;
alter default privileges in schema raw, core, mart, audit grant all on sequences to service_role;
alter default privileges in schema raw, core, mart, audit grant execute on functions to service_role;

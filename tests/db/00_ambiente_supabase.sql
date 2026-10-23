-- Só para testes locais: recria os papéis que o Supabase já tem e um
-- conjunto mínimo de asserções. Não é aplicado no projeto real.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin bypassrls;
  end if;
end
$$;

create schema if not exists teste;

create or replace function teste.igual(p_obtido anyelement, p_esperado anyelement, p_msg text)
returns void
language plpgsql
as $$
begin
  if p_obtido is distinct from p_esperado then
    raise exception 'FALHOU: % (obtido: %, esperado: %)', p_msg, p_obtido, p_esperado;
  end if;
end
$$;

create or replace function teste.verdade(p_cond boolean, p_msg text)
returns void
language plpgsql
as $$
begin
  if p_cond is not true then
    raise exception 'FALHOU: %', p_msg;
  end if;
end
$$;

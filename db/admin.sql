-- Área de administração — Melo Tecnologia
-- Roda depois de schema.sql. Idempotente.

create table if not exists admins (
  email text primary key,
  criado_em timestamptz default now()
);

insert into admins (email) values ('eduardo@meloinfo.com.br')
on conflict (email) do nothing;

alter table admins enable row level security;
-- sem políticas: ninguém lê essa tabela pela API pública

create or replace function e_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from admins a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  );
$$;

grant execute on function e_admin() to authenticated;

drop policy if exists "cliente le seu projeto" on projetos;
drop policy if exists "le projeto" on projetos;
create policy "le projeto" on projetos
  for select to authenticated
  using (lower(cliente_email) = lower(auth.jwt() ->> 'email') or e_admin());

drop policy if exists "admin edita projeto" on projetos;
create policy "admin edita projeto" on projetos
  for update to authenticated
  using (e_admin()) with check (e_admin());

drop policy if exists "cliente le seus itens" on itens;
drop policy if exists "le itens" on itens;
create policy "le itens" on itens
  for select to authenticated
  using (e_dono(projeto_id) or e_admin());

drop policy if exists "admin edita itens" on itens;
create policy "admin edita itens" on itens
  for update to authenticated
  using (e_admin()) with check (e_admin());

drop policy if exists "cliente le seus pagamentos" on pagamentos;
drop policy if exists "le pagamentos" on pagamentos;
create policy "le pagamentos" on pagamentos
  for select to authenticated
  using (e_dono(projeto_id) or e_admin());

drop policy if exists "admin edita pagamentos" on pagamentos;
create policy "admin edita pagamentos" on pagamentos
  for update to authenticated
  using (e_admin()) with check (e_admin());

-- grants por coluna: o cliente segue limitado às colunas de resposta;
-- o admin só precisa destas para mover etapa e quitar pagamento
grant update (status) on projetos to authenticated;
grant update (status, pago_em) on pagamentos to authenticated;

drop policy if exists "admin le material" on storage.objects;
create policy "admin le material" on storage.objects
  for select to authenticated
  using (bucket_id = 'materiais' and e_admin());

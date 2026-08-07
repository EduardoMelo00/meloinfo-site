-- Portal do cliente — Melo Tecnologia
-- Cole este arquivo inteiro no SQL Editor do Supabase e execute.

create table if not exists projetos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cliente_nome text not null,
  cliente_email text not null,
  status text not null default 'aguardando_materiais',
  prazo_dias int default 10,
  iniciado_em date,
  proposta_url text,
  criado_em timestamptz default now()
);

create table if not exists itens (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid not null references projetos(id) on delete cascade,
  tipo text not null check (tipo in ('etapa', 'requisito')),
  titulo text not null,
  descricao text,
  campo_tipo text check (campo_tipo in ('texto', 'email', 'moeda', 'arquivo', 'instrucao', 'confirmacao')),
  obrigatorio boolean not null default true,
  ordem int not null default 0,
  status text not null default 'pendente' check (status in ('pendente', 'enviado', 'concluido')),
  valor_texto text,
  arquivo_path text,
  atualizado_em timestamptz
);

create table if not exists pagamentos (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid not null references projetos(id) on delete cascade,
  descricao text not null,
  valor_centavos int not null,
  status text not null default 'pendente' check (status in ('pendente', 'pago')),
  pago_em date,
  ordem int not null default 0
);

create index if not exists itens_projeto_idx on itens (projeto_id, tipo, ordem);
create index if not exists pagamentos_projeto_idx on pagamentos (projeto_id, ordem);
create index if not exists projetos_email_idx on projetos (lower(cliente_email));

alter table projetos enable row level security;
alter table itens enable row level security;
alter table pagamentos enable row level security;

create or replace function e_dono(p_projeto_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from projetos p
    where p.id = p_projeto_id
      and lower(p.cliente_email) = lower(auth.jwt() ->> 'email')
  );
$$;

drop policy if exists "cliente le seu projeto" on projetos;
create policy "cliente le seu projeto" on projetos
  for select to authenticated
  using (lower(cliente_email) = lower(auth.jwt() ->> 'email'));

drop policy if exists "cliente le seus itens" on itens;
create policy "cliente le seus itens" on itens
  for select to authenticated
  using (e_dono(projeto_id));

drop policy if exists "cliente responde requisitos" on itens;
create policy "cliente responde requisitos" on itens
  for update to authenticated
  using (e_dono(projeto_id) and tipo = 'requisito')
  with check (e_dono(projeto_id) and tipo = 'requisito');

drop policy if exists "cliente le seus pagamentos" on pagamentos;
create policy "cliente le seus pagamentos" on pagamentos
  for select to authenticated
  using (e_dono(projeto_id));

revoke update on itens from authenticated;
grant update (valor_texto, arquivo_path, status, atualizado_em) on itens to authenticated;

insert into storage.buckets (id, name, public)
values ('materiais', 'materiais', false)
on conflict (id) do nothing;

drop policy if exists "cliente envia material" on storage.objects;
create policy "cliente envia material" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'materiais'
    and e_dono(((storage.foldername(name))[1])::uuid)
  );

drop policy if exists "cliente le material" on storage.objects;
create policy "cliente le material" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'materiais'
    and e_dono(((storage.foldername(name))[1])::uuid)
  );

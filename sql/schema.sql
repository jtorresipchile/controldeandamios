-- Ejecutar en Supabase > SQL Editor
create table perfiles (
  id uuid primary key references auth.users on delete cascade,
  email text, nombre text,
  rol text not null check (rol in ('admin','bodega'))
);
create table elementos (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  unidad text not null default 'un'
);
create table movimientos (
  id bigint generated always as identity primary key,
  guia text not null,
  tipo text not null check (tipo in ('recepcion','devolucion')),
  fecha date not null default current_date,
  elemento_id bigint not null references elementos(id) on delete restrict,
  cantidad numeric not null check (cantidad > 0),
  observacion text,
  creado_por uuid default auth.uid(),
  created_at timestamptz default now()
);

create function es_admin() returns boolean language sql security definer stable as
$$ select exists(select 1 from perfiles where id = auth.uid() and rol = 'admin') $$;
create function tiene_perfil() returns boolean language sql security definer stable as
$$ select exists(select 1 from perfiles where id = auth.uid()) $$;

alter table perfiles enable row level security;
alter table elementos enable row level security;
alter table movimientos enable row level security;

create policy perfiles_sel on perfiles for select using (id = auth.uid() or es_admin());
create policy perfiles_ins on perfiles for insert with check (es_admin());
create policy perfiles_upd on perfiles for update using (es_admin());
create policy perfiles_del on perfiles for delete using (es_admin());

create policy elem_sel on elementos for select using (tiene_perfil());
create policy elem_ins on elementos for insert with check (es_admin());
create policy elem_upd on elementos for update using (es_admin());
create policy elem_del on elementos for delete using (es_admin());

create policy mov_sel on movimientos for select using (tiene_perfil());
create policy mov_ins on movimientos for insert with check (tiene_perfil());
create policy mov_del on movimientos for delete using (es_admin());

-- PRIMER ADMIN: crea el usuario en Authentication > Users (Add user, con "Auto confirm"),
-- copia su UUID y ejecuta:
-- insert into perfiles (id, email, nombre, rol) values ('UUID-AQUI','admin@tucorreo.cl','Administrador','admin');
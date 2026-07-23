-- =============================================================
-- Migration 001 — Schema completo do Você viu meu pet?
-- =============================================================

-- 1. Extensões necessárias
create extension if not exists postgis;
create extension if not exists "uuid-ossp";

-- =============================================================
-- 2. Tabela: profiles
-- =============================================================
create table if not exists public.profiles (
  id          uuid        primary key references auth.users(id) on delete cascade,
  username    text        unique not null,
  full_name   text        not null,
  avatar_url  text,
  city        text,
  phone       text,
  push_token  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Trigger para criar perfil automaticamente ao registrar usuário
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================
-- 3. Tabela: pets
-- =============================================================
create table if not exists public.pets (
  id           uuid        primary key default gen_random_uuid(),
  owner_id     uuid        not null references public.profiles(id) on delete cascade,
  name         text        not null,
  species      text        not null check (species in ('dog','cat','bird','rabbit','other')),
  breed        text,
  color        text        not null,
  size         text        not null check (size in ('small','medium','large')),
  age_approx   text,
  description  text        not null,
  reward       text,
  status       text        not null default 'active' check (status in ('active','found','closed')),
  lost_at      timestamptz not null,
  lost_lat     float8      not null,
  lost_lng     float8      not null,
  lost_address text        not null,
  photos       text[]      not null default '{}',
  location     geography(point),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Índice espacial
create index if not exists pets_location_idx on public.pets using gist (location);

-- Trigger para manter a coluna `location` atualizada
create or replace function public.update_pet_location()
returns trigger language plpgsql as $$
begin
  if new.lost_lat is not null and new.lost_lng is not null then
    new.location := st_point(new.lost_lng, new.lost_lat)::geography;
  end if;
  return new;
end;
$$;

drop trigger if exists tr_update_pet_location on public.pets;
create trigger tr_update_pet_location
  before insert or update of lost_lat, lost_lng on public.pets
  for each row execute function public.update_pet_location();

-- =============================================================
-- 4. Tabela: sightings (avistamentos)
-- =============================================================
create table if not exists public.sightings (
  id          uuid        primary key default gen_random_uuid(),
  pet_id      uuid        not null references public.pets(id) on delete cascade,
  reporter_id uuid        not null references public.profiles(id),
  photo_url   text        not null,
  lat         float8      not null,
  lng         float8      not null,
  address     text        not null,
  description text,
  seen_at     timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

create index if not exists sightings_pet_id_idx on public.sightings(pet_id);

-- =============================================================
-- 5. Tabela: comments
-- =============================================================
create table if not exists public.comments (
  id         uuid        primary key default gen_random_uuid(),
  pet_id     uuid        not null references public.pets(id) on delete cascade,
  author_id  uuid        not null references public.profiles(id),
  content    text        not null check (char_length(content) <= 500),
  is_pinned  boolean     not null default false,
  created_at timestamptz not null default now()
);

create index if not exists comments_pet_id_idx on public.comments(pet_id);

-- =============================================================
-- 6. Tabela: notifications
-- =============================================================
create table if not exists public.notifications (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references public.profiles(id) on delete cascade,
  type        text        not null,
  pet_id      uuid        references public.pets(id) on delete cascade,
  sighting_id uuid        references public.sightings(id) on delete set null,
  message     text        not null,
  read        boolean     not null default false,
  created_at  timestamptz not null default now()
);

create index if not exists notifications_user_id_idx on public.notifications(user_id);

-- =============================================================
-- 7. Função RPC: busca por proximidade (PostGIS)
-- =============================================================
create or replace function public.search_nearby_pets(
  user_lat       double precision,
  user_lng       double precision,
  radius_meters  double precision,
  species_filter text    default null,
  page_num       integer default 0,
  page_size      integer default 20
)
returns table (
  id           uuid,
  name         text,
  species      text,
  breed        text,
  color        text,
  size         text,
  age_approx   text,
  description  text,
  lost_at      timestamptz,
  lost_address text,
  lost_lat     double precision,
  lost_lng     double precision,
  photos       text[],
  reward       text,
  status       text,
  owner_id     uuid,
  created_at   timestamptz,
  updated_at   timestamptz,
  dist_meters  double precision,
  profile_name text,
  profile_avatar text
)
language plpgsql as $$
begin
  return query
  select
    p.id, p.name, p.species, p.breed, p.color, p.size, p.age_approx,
    p.description, p.lost_at, p.lost_address, p.lost_lat, p.lost_lng,
    p.photos, p.reward, p.status, p.owner_id, p.created_at, p.updated_at,
    st_distance(p.location, st_point(user_lng, user_lat)::geography) as dist_meters,
    pr.full_name  as profile_name,
    pr.avatar_url as profile_avatar
  from public.pets p
  left join public.profiles pr on pr.id = p.owner_id
  where p.status = 'active'
    and (species_filter is null or p.species = species_filter)
    and st_dwithin(p.location, st_point(user_lng, user_lat)::geography, radius_meters)
  order by dist_meters asc, p.created_at desc
  limit page_size
  offset page_num * page_size;
end;
$$;

-- =============================================================
-- 8. Row Level Security (RLS)
-- =============================================================
alter table public.profiles      enable row level security;
alter table public.pets          enable row level security;
alter table public.sightings     enable row level security;
alter table public.comments      enable row level security;
alter table public.notifications enable row level security;

-- profiles
create policy "Perfis publicos para leitura"  on public.profiles for select using (true);
create policy "Usuario gerencia proprio perfil" on public.profiles for all using (auth.uid() = id);

-- pets
create policy "Pets ativos visiveis publicamente"  on public.pets for select using (status = 'active' or owner_id = auth.uid());
create policy "Dono cria pets"                     on public.pets for insert with check (auth.uid() = owner_id);
create policy "Dono atualiza pets"                 on public.pets for update using (auth.uid() = owner_id);
create policy "Dono exclui pets"                   on public.pets for delete using (auth.uid() = owner_id);

-- sightings
create policy "Avistamentos visiveis publicamente" on public.sightings for select using (true);
create policy "Usuario autenticado cria avistamento" on public.sightings for insert with check (auth.uid() = reporter_id);
create policy "Reporter exclui avistamento" on public.sightings for delete using (auth.uid() = reporter_id);

-- comments
create policy "Comentarios visiveis publicamente" on public.comments for select using (true);
create policy "Usuario autenticado comenta"       on public.comments for insert with check (auth.uid() = author_id);
create policy "Autor exclui comentario"           on public.comments for delete using (auth.uid() = author_id);
create policy "Dono do pet fixa comentario"       on public.comments for update using (
  auth.uid() = author_id or
  auth.uid() = (select owner_id from public.pets where id = pet_id)
);

-- notifications
create policy "Usuario ve proprias notificacoes"    on public.notifications for select using (auth.uid() = user_id);
create policy "Sistema cria notificacoes"           on public.notifications for insert with check (true);
create policy "Usuario marca notificacao como lida" on public.notifications for update using (auth.uid() = user_id);

-- =============================================================
-- 9. Storage buckets
-- =============================================================
insert into storage.buckets (id, name, public)
values
  ('pet-photos',      'pet-photos',      true),
  ('sighting-photos', 'sighting-photos', true),
  ('avatars',         'avatars',         true)
on conflict (id) do nothing;

-- Politicas de Storage
create policy "Fotos de pets publicas"      on storage.objects for select using (bucket_id = 'pet-photos');
create policy "Upload fotos de pet"         on storage.objects for insert with check (bucket_id = 'pet-photos' and auth.role() = 'authenticated');
create policy "Fotos de avistamento publicas" on storage.objects for select using (bucket_id = 'sighting-photos');
create policy "Upload fotos de avistamento" on storage.objects for insert with check (bucket_id = 'sighting-photos' and auth.role() = 'authenticated');
create policy "Avatares publicos"           on storage.objects for select using (bucket_id = 'avatars');
create policy "Upload avatar"               on storage.objects for insert with check (bucket_id = 'avatars' and auth.role() = 'authenticated');
create policy "Atualizar avatar"            on storage.objects for update with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

-- =============================================================
-- 10. Grants (Permissoes de acesso para a API)
-- =============================================================
grant usage on schema public to anon, authenticated;

-- SEGURANÇA: Grants específicos e restritivos em vez de "all privileges"
-- Princípio do Menor Privilégio (Principle of Least Privilege)
-- Delete é controlado por RLS policies, não via grants

-- profiles table
-- anon: somente leitura (select) - pode ver perfis públicos via RLS
-- authenticated: read, create/update próprio perfil via RLS
grant select on table public.profiles to anon;
grant select, insert, update on table public.profiles to authenticated;

-- pets table
-- anon: somente leitura (select) - vê pets ativos via RLS
-- authenticated: read tudo, cria/atualiza/deleta próprios pets via RLS
grant select on table public.pets to anon;
grant select, insert, update, delete on table public.pets to authenticated;

-- sightings table
-- anon: somente leitura (select) - vê avistamentos via RLS
-- authenticated: read tudo, cria/deleta próprios avistamentos via RLS
grant select on table public.sightings to anon;
grant select, insert, delete on table public.sightings to authenticated;

-- comments table
-- anon: somente leitura (select) - vê comentários via RLS
-- authenticated: read tudo, cria/deleta próprios comentários, atualiza (only_pinned) via RLS
grant select on table public.comments to anon;
grant select, insert, update, delete on table public.comments to authenticated;

-- notifications table
-- anon: SEM ACESSO (não adiciona grant)
-- authenticated: read próprias notificações, atualiza próprias notificações via RLS
-- Insert permitido apenas para sistema (service_role)
grant select, update on table public.notifications to authenticated;

-- RPC function - acessível publicamente para busca
grant execute on function public.search_nearby_pets to anon, authenticated;

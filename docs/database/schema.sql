-- ============================================================
-- Schema SQL — Você viu meu animal de estimação?
-- Executar no Supabase SQL Editor
-- ============================================================

-- Habilitar extensão para UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TABELA: profiles
-- Estende o auth.users do Supabase
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    TEXT UNIQUE NOT NULL,
  full_name   TEXT NOT NULL,
  avatar_url  TEXT,
  city        TEXT,
  phone       TEXT,
  push_token  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger: criar perfil automaticamente após signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TABELA: pets
-- Animais perdidos cadastrados pelos donos
-- ============================================================
CREATE TABLE IF NOT EXISTS public.pets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  species       TEXT NOT NULL CHECK (species IN ('dog','cat','bird','rabbit','other')),
  breed         TEXT,
  color         TEXT NOT NULL,
  size          TEXT NOT NULL CHECK (size IN ('small','medium','large')),
  age_approx    TEXT,
  description   TEXT NOT NULL,
  reward        TEXT,
  status        TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','found','closed')),
  lost_at       TIMESTAMPTZ NOT NULL,
  lost_lat      FLOAT8 NOT NULL,
  lost_lng      FLOAT8 NOT NULL,
  lost_address  TEXT NOT NULL,
  photos        TEXT[] NOT NULL DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para buscas por status e localização
CREATE INDEX IF NOT EXISTS pets_status_idx ON public.pets(status);
CREATE INDEX IF NOT EXISTS pets_owner_idx ON public.pets(owner_id);
CREATE INDEX IF NOT EXISTS pets_location_idx ON public.pets(lost_lat, lost_lng);
CREATE INDEX IF NOT EXISTS pets_species_idx ON public.pets(species);

-- Trigger: atualizar updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER pets_updated_at
  BEFORE UPDATE ON public.pets
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- TABELA: sightings
-- Avistamentos registrados por outros usuários
-- ============================================================
CREATE TABLE IF NOT EXISTS public.sightings (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id        UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  reporter_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  photo_url     TEXT NOT NULL,
  lat           FLOAT8 NOT NULL,
  lng           FLOAT8 NOT NULL,
  address       TEXT NOT NULL,
  description   TEXT,
  seen_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS sightings_pet_idx ON public.sightings(pet_id);
CREATE INDEX IF NOT EXISTS sightings_reporter_idx ON public.sightings(reporter_id);

-- ============================================================
-- TABELA: comments
-- Comentários nas publicações de animais perdidos
-- ============================================================
CREATE TABLE IF NOT EXISTS public.comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  author_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL CHECK (length(content) <= 500),
  is_pinned   BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS comments_pet_idx ON public.comments(pet_id);

-- ============================================================
-- TABELA: notifications
-- Notificações in-app para os usuários
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type          TEXT NOT NULL CHECK (type IN ('new_sighting','new_comment','pet_nearby')),
  pet_id        UUID REFERENCES public.pets(id) ON DELETE CASCADE,
  sighting_id   UUID REFERENCES public.sightings(id) ON DELETE CASCADE,
  message       TEXT NOT NULL,
  read          BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_user_idx ON public.notifications(user_id, read);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_all" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- pets
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "pets_select_all" ON public.pets
  FOR SELECT USING (true);

CREATE POLICY "pets_insert_authenticated" ON public.pets
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "pets_update_own" ON public.pets
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "pets_delete_own" ON public.pets
  FOR DELETE USING (auth.uid() = owner_id);

-- sightings
ALTER TABLE public.sightings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sightings_select_all" ON public.sightings
  FOR SELECT USING (true);

CREATE POLICY "sightings_insert_authenticated" ON public.sightings
  FOR INSERT WITH CHECK (
    auth.uid() = reporter_id AND
    auth.uid() != (SELECT owner_id FROM public.pets WHERE id = pet_id)
  );

CREATE POLICY "sightings_delete_own" ON public.sightings
  FOR DELETE USING (auth.uid() = reporter_id);

-- comments
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comments_select_all" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "comments_insert_authenticated" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "comments_delete_own" ON public.comments
  FOR DELETE USING (auth.uid() = author_id);

CREATE POLICY "comments_update_pin" ON public.comments
  FOR UPDATE USING (
    auth.uid() = (SELECT owner_id FROM public.pets WHERE id = pet_id)
  );

-- notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_select_own" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "notifications_insert_service" ON public.notifications
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- STORAGE BUCKETS
-- Executar via Supabase Dashboard > Storage
-- ============================================================
-- bucket: "pet-photos"     → fotos dos animais perdidos
-- bucket: "sighting-photos" → fotos dos avistamentos
-- bucket: "avatars"        → fotos de perfil dos usuários
--
-- Configuração recomendada para cada bucket:
--   Public: true (acesso de leitura público)
--   File size limit: 5MB
--   Allowed MIME types: image/jpeg, image/png, image/webp
-- ============================================================

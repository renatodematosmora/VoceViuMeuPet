-- =============================================================
-- Seed data para desenvolvimento local
-- =============================================================

-- Usuário de teste (criado via Supabase Auth diretamente)
-- Execute: supabase users create --email test@test.com --password test1234

-- Pets de exemplo (inseridos após criar usuário manualmente)
-- Os dados de seed ficam aqui para referência do desenvolvimento.

-- Exemplo de como inserir após ter um user_id real:
-- insert into public.pets (owner_id, name, species, color, size, description, lost_at, lost_lat, lost_lng, lost_address, photos)
-- values (
--   '<SEU_USER_ID>',
--   'Rex',
--   'dog',
--   'Preto e branco',
--   'medium',
--   'Cachorro brincalhão, usa coleira vermelha',
--   now() - interval '2 days',
--   -23.5505,
--   -46.6333,
--   'Av. Paulista, São Paulo - SP',
--   '{}'
-- );

select 'Seed executado com sucesso!' as status;

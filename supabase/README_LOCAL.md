# 🐾 Ambiente de Desenvolvimento Local — Você viu meu Pet?

Este guia explica como rodar o app **completamente local** usando Docker + Supabase CLI.

## Pré-requisitos

| Ferramenta | Instalação |
|---|---|
| **Docker Desktop** | https://docs.docker.com/desktop/windows/ |
| **Supabase CLI** | Já instalado em `WindowsApps/supabase.exe` |
| **Flutter SDK** | Já instalado |

## Subindo o ambiente local

### Opção 1 — Script automático (recomendado)
```powershell
.\scripts\dev_local.ps1
```

### Opção 2 — Manual
```powershell
# 1. Subir o Supabase (primeira vez baixa ~1GB de imagens Docker)
supabase start

# 2. Ver as credenciais geradas
supabase status

# 3. Rodar o Flutter apontando para o local
flutter run `
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
  --dart-define=SUPABASE_ANON_KEY=<anon_key_do_output_acima>
```

## URLs do ambiente local

| Serviço | URL |
|---|---|
| **API (PostgREST)** | http://127.0.0.1:54321 |
| **Supabase Studio** | http://127.0.0.1:54323 |
| **Inbucket (e-mails)** | http://127.0.0.1:54324 |
| **PostgreSQL direto** | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |

## Reiniciar o banco com migrations limpas

```powershell
# Apaga todos os dados e refaz as migrations do zero
supabase db reset
```

## Parar o ambiente

```powershell
supabase stop
```

## Como funciona

```
App Flutter
    │ --dart-define=SUPABASE_URL=http://127.0.0.1:54321
    ▼
Supabase CLI (Docker)
    ├── PostgreSQL 17 + PostGIS  → porta 54322
    ├── PostgREST (API REST)     → porta 54321
    ├── GoTrue (Auth)            → porta 54321/auth
    ├── Realtime                 → porta 54321/realtime
    ├── Storage                  → porta 54321/storage
    └── Studio (Dashboard)       → porta 54323
```

## Dica — Criando usuário de teste

No Studio (`http://127.0.0.1:54323`) → Authentication → Users → Add user

Ou via CLI:
```powershell
supabase users create --email dev@test.com --password test1234
```

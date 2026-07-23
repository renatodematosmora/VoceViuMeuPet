#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Inicia o ambiente Supabase local e o app Flutter apontando para ele.

.DESCRIPTION
    Este script:
    1. Sobe o Supabase local via Docker (supabase start)
    2. Exibe as credenciais do ambiente local
    3. Roda o Flutter com as variáveis corretas apontando para o local

.USAGE
    .\scripts\dev_local.ps1
#>

Write-Host "🐾 Você viu meu Pet? — Ambiente Local" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Checar dependências
if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
    Write-Error "Supabase CLI não encontrado. Siga as instruções em supabase/README_LOCAL.md"
    exit 1
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker não encontrado. Instale o Docker Desktop primeiro."
    exit 1
}

# Checar se Docker está rodando
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker não está rodando. Abra o Docker Desktop e tente novamente."
    exit 1
}

# Subir o Supabase local
Write-Host "`n📦 Iniciando Supabase local..." -ForegroundColor Yellow
$statusOutput = supabase status 2>&1
if ($statusOutput -like "*supabase local development setup is running*") {
    Write-Host "✅ Supabase já está rodando!" -ForegroundColor Green
} else {
    Write-Host "   Aguarde, isso pode demorar na primeira vez..." -ForegroundColor Gray
    supabase start
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao iniciar Supabase. Verifique os logs acima."
        exit 1
    }
}

# Obter credenciais
$statusJson = supabase status --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
if ($statusJson) {
    $localUrl    = $statusJson.API_URL
    $localAnonKey = $statusJson.ANON_KEY
} else {
    # Fallback para valores padrão
    $localUrl    = "http://127.0.0.1:54321"
    $localAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRFA0NiK7CcryFh7AlEcn1YqAuiGASg37fxVXiI8FDg"
}

Write-Host "`n✅ Supabase Local rodando!" -ForegroundColor Green
Write-Host "   API URL:   $localUrl" -ForegroundColor White
Write-Host "   Studio:    http://127.0.0.1:54323" -ForegroundColor White
Write-Host "   Inbucket:  http://127.0.0.1:54324 (e-mails de teste)" -ForegroundColor White
Write-Host "   DB:        postgresql://postgres:postgres@127.0.0.1:54322/postgres" -ForegroundColor White

# Rodar o Flutter com as variáveis de ambiente locais
Write-Host "`n📱 Iniciando Flutter apontando para ambiente local..." -ForegroundColor Yellow

flutter run `
    --dart-define=SUPABASE_URL=$localUrl `
    --dart-define=SUPABASE_ANON_KEY=$localAnonKey

Write-Host "`n🛑 Para parar o Supabase local: supabase stop" -ForegroundColor Gray

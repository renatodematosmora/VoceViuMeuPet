# 🔐 Checklist de Segurança — Antes de Subir para o Repositório

> Criado em 2026-07-23 após varredura de segurança do repositório.
> Objetivo: evitar repetir os erros que expuseram arquivos locais e uma chave
> hardcoded no primeiro push.

## Erros cometidos no primeiro push (lições aprendidas)

| Erro | O que aconteceu | Correção aplicada |
|------|-----------------|-------------------|
| `.claude/settings.local.json` commitado | Expôs caminho do usuário (`C:\Users\Renat\...`) e allowlist de comandos | Adicionado ao `.gitignore` + removido do histórico |
| `supabase/.temp/` e `.branches/` commitados | Cache do Supabase CLI (~13k linhas), expõe schema do banco | Adicionado ao `.gitignore` + removido do histórico |
| Chave anon hardcoded no código | `supabase_constants.dart` tinha a chave demo embutida como fallback (a "Fase 1" não removeu de fato) | Migrado para `String.fromEnvironment` (via `--dart-define`) |

> Nota: a chave que estava hardcoded era a **chave demo pública do Supabase local**
> (`iss: supabase-demo`), que só funciona contra `127.0.0.1`. Não houve vazamento
> de segredo real (nenhuma `service_role`, senha de produção ou token de API privado).

## ✅ Checklist antes de cada `git push`

### 1. Arquivos que NUNCA devem ser versionados
- [ ] `.env` e variantes (`.env.local`, `.env.*.local`) — **só** `.env.example` pode subir
- [ ] `.claude/` — configuração local da máquina (caminhos, permissões, workflow)
- [ ] `supabase/.temp/`, `supabase/.branches/` — cache regenerável do CLI
- [ ] Arquivos `*.local.*`, `*.key`, `*.pem`, `*.p12`, `*.keystore`, `*.jks`
- [ ] Credenciais de assinatura (`android/key.properties`, `*.mobileprovision`)

### 2. Segredos no código
- [ ] Nenhuma `service_role` key do Supabase (essa é privada — só no backend/env)
- [ ] Nenhum token de API (Firebase, Twilio, SendGrid, OpenAI, AWS) hardcoded
- [ ] Chaves/URLs vêm de `String.fromEnvironment` / `--dart-define` / env vars
- [ ] `config.toml` usa `env(...)` para todos os segredos (nunca valor literal)

### 3. Comandos de verificação (rodar antes do push)
```bash
# Ver exatamente o que será commitado
git status
git diff --cached --stat

# Procurar segredos reais no que está rastreado (não deve retornar nada relevante)
git grep -inE "service_role|sk_live|sk_test|AKIA|-----BEGIN|ghp_|xox[baprs]-"

# Confirmar que arquivos locais NÃO estão rastreados
git ls-files | grep -E "^\.claude|\.env$|\.temp/|\.branches/"
```

### 4. Se um segredo REAL vazar (não foi o caso aqui)
1. **Rotacionar/revogar a chave imediatamente** no provedor — reescrever histórico não basta, ela já foi exposta
2. Remover do código e mover para env
3. Reescrever o histórico (`git filter-repo` ou `filter-branch`) + `git push --force`
4. Avisar quem tem clones do repositório

## 🛠️ Como rodar localmente (sem chave hardcoded)

O `.vscode/launch.json` já injeta a chave demo local via `--dart-define`.
Pela linha de comando:
```bash
flutter run \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
  --dart-define=SUPABASE_ANON_KEY=<chave-anon-local>
```
Para produção, defina `SUPABASE_URL` e `SUPABASE_ANON_KEY` no pipeline de CI/CD.

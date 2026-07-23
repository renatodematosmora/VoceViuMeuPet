# Feature Specifications — Você viu meu animal de estimação? 🐾

> Documento de especificação para desenvolvimento orientado a specs (Spec-Driven Development).
> Cada feature define comportamento esperado, regras de negócio, modelos de dados e critérios de aceitação.

---

## FEAT-01: Autenticação e Gestão de Conta

### Descrição
Permite que usuários criem contas, façam login e gerenciem sua sessão.

### Fluxos
1. **Cadastro**: Usuário informa nome completo, e-mail e senha → Recebe e-mail de confirmação → Confirma conta → Redirecionado ao app
2. **Login**: Usuário informa e-mail e senha → Autenticado → Redirecionado ao Feed
3. **Logout**: Usuário encerra sessão → Token invalidado → Redirecionado à tela de Login

### Regras de Negócio
- Senha mínima: 8 caracteres
- E-mail deve ser único no sistema
- Sessão persiste entre reabertura do app (token salvo localmente)
- Após 3 tentativas de login incorretas, bloquear por 60 segundos

### Modelos de Dados
```
profiles {
  id: UUID (PK, refs auth.users)
  username: TEXT UNIQUE NOT NULL
  full_name: TEXT NOT NULL
  avatar_url: TEXT
  city: TEXT
  phone: TEXT
  push_token: TEXT
  created_at: TIMESTAMPTZ DEFAULT now()
  updated_at: TIMESTAMPTZ DEFAULT now()
}
```

### Critérios de Aceitação
- [ ] Usuário consegue criar conta com e-mail válido
- [ ] Usuário consegue fazer login com credenciais corretas
- [ ] Erro claro exibido para credenciais inválidas
- [ ] Sessão persiste ao fechar e reabrir o app
- [ ] Logout funciona e redireciona corretamente

---

## FEAT-02: Perfil de Usuário

### Descrição
Permite que usuários visualizem e editem seu perfil público.

### Fluxos
1. **Ver Perfil**: Tela com avatar, nome, cidade, animais cadastrados pelo usuário
2. **Editar Perfil**: Formulário para alterar nome, cidade, telefone e foto de perfil
3. **Ver Perfil Alheio**: Qualquer usuário pode ver o perfil público de outro

### Regras de Negócio
- Foto de perfil redimensionada para máximo 512x512px antes do upload
- Telefone é opcional e não exibido publicamente
- Usuário pode ver apenas seus próprios animais no perfil

### Critérios de Aceitação
- [ ] Foto de perfil pode ser alterada via câmera ou galeria
- [ ] Alterações salvas com feedback visual (loading + sucesso)
- [ ] Perfil de outros usuários é somente leitura

---

## FEAT-03: Cadastro de Animal Perdido

### Descrição
O dono cadastra seu animal desaparecido com fotos e informações detalhadas.

### Fluxos
1. **Passo 1 — Fotos**: Upload de 1 a 5 fotos (câmera ou galeria)
2. **Passo 2 — Dados Básicos**: Nome, espécie, raça, cor, porte, idade aproximada
3. **Passo 3 — Desaparecimento**: Data/hora, localização no mapa (pin), endereço, descrição
4. **Passo 4 — Extras**: Recompensa (texto livre), informações de contato adicionais
5. **Confirmação**: Revisão e publicação

### Regras de Negócio
- Ao menos 1 foto é obrigatória
- Localização é obrigatória (GPS automático ou seleção manual no mapa)
- Status inicial sempre `ATIVO`
- Espécies: cachorro, gato, pássaro, coelho, outro
- Portes: pequeno (<10kg), médio (10-25kg), grande (>25kg)
- Máximo 5 fotos por publicação
- Fotos comprimidas para máximo 1024x1024px antes do upload

### Modelos de Dados
```
pets {
  id: UUID (PK, DEFAULT gen_random_uuid())
  owner_id: UUID NOT NULL REFS profiles(id) ON DELETE CASCADE
  name: TEXT NOT NULL
  species: TEXT NOT NULL  -- 'dog'|'cat'|'bird'|'rabbit'|'other'
  breed: TEXT
  color: TEXT NOT NULL
  size: TEXT NOT NULL     -- 'small'|'medium'|'large'
  age_approx: TEXT
  description: TEXT NOT NULL
  reward: TEXT
  status: TEXT NOT NULL DEFAULT 'active'  -- 'active'|'found'|'closed'
  lost_at: TIMESTAMPTZ NOT NULL
  lost_lat: FLOAT8 NOT NULL
  lost_lng: FLOAT8 NOT NULL
  lost_address: TEXT NOT NULL
  photos: TEXT[] NOT NULL   -- array de URLs do Storage
  created_at: TIMESTAMPTZ DEFAULT now()
  updated_at: TIMESTAMPTZ DEFAULT now()
}
```

### Critérios de Aceitação
- [ ] Formulário multi-etapa com progresso visual
- [ ] Upload de múltiplas fotos funciona
- [ ] Mapa abre com localização atual do usuário como padrão
- [ ] Usuário pode mover o pin no mapa para ajustar localização
- [ ] Endereço é preenchido automaticamente via geocoding reverso
- [ ] Animal publicado aparece no Feed imediatamente
- [ ] Fotos exibidas em carrossel na tela de detalhe

---

## FEAT-04: Feed Principal

### Descrição
Lista todos os animais perdidos com status `ATIVO`, ordenados por proximidade ou data.

### Fluxos
1. **Carregamento**: Feed carrega os 20 primeiros animais (paginação)
2. **Scroll Infinito**: Ao chegar no fim, carrega próximos 20
3. **Filtros**: Por espécie, raio de distância (5km, 10km, 25km, 50km, estado inteiro)
4. **Ordenação**: Por data (mais recente) ou por proximidade (GPS do usuário)

### Regras de Negócio
- Apenas animais com status `ATIVO` aparecem no feed
- Se localização do usuário não disponível, ordenar por data
- Pull-to-refresh recarrega o feed do início
- Card do feed exibe: foto principal, nome, espécie, dias desaparecido, cidade, distância (se disponível)

### Critérios de Aceitação
- [ ] Feed carrega em menos de 3 segundos
- [ ] Filtros funcionam corretamente
- [ ] Paginação funciona (scroll infinito)
- [ ] Pull-to-refresh funciona
- [ ] Card exibe informações corretas
- [ ] Toque no card abre detalhe do animal

---

## FEAT-05: Detalhe do Animal

### Descrição
Tela completa com todas as informações do animal, galeria de fotos, avistamentos e comentários.

### Fluxos
1. **Visualização**: Foto em carrossel, dados do animal, mapa, lista de avistamentos
2. **Avistamento**: Botão "Vi este animal!" abre tela de registro de avistamento
3. **Comentário**: Campo de texto para adicionar comentário
4. **Ações do Dono**: Editar publicação, marcar como encontrado, encerrar busca

### Regras de Negócio
- Dono não pode registrar avistamento do próprio animal
- Avistamentos exibidos em ordem cronológica inversa
- Comentários exibidos em ordem cronológica
- Dono pode fixar (pin) até 3 comentários no topo
- Botão de compartilhar gera deep link da publicação

### Critérios de Aceitação
- [ ] Galeria de fotos com swipe funciona
- [ ] Mapa mostra local do desaparecimento + avistamentos
- [ ] Lista de avistamentos mostra foto, data e localização
- [ ] Comentários carregam corretamente
- [ ] Usuário não-dono vê botão "Vi este animal!"
- [ ] Dono vê botões de gerenciamento

---

## FEAT-06: Registro de Avistamento

### Descrição
Qualquer usuário (exceto o dono) pode registrar um avistamento com foto e localização.

### Fluxos
1. **Câmera/Galeria**: Usuário tira ou seleciona foto do animal visto
2. **Localização**: GPS automático ou seleção manual no mapa
3. **Descrição**: Campo de texto opcional
4. **Envio**: Salva avistamento → Notifica o dono via push

### Regras de Negócio
- Foto é OBRIGATÓRIA
- Localização é OBRIGATÓRIA
- Apenas usuários autenticados podem registrar avistamentos
- Dono do animal NÃO pode registrar avistamentos do próprio animal
- Após envio, dono recebe notificação push imediata

### Modelos de Dados
```
sightings {
  id: UUID (PK)
  pet_id: UUID NOT NULL REFS pets(id) ON DELETE CASCADE
  reporter_id: UUID NOT NULL REFS profiles(id)
  photo_url: TEXT NOT NULL
  lat: FLOAT8 NOT NULL
  lng: FLOAT8 NOT NULL
  address: TEXT NOT NULL
  description: TEXT
  seen_at: TIMESTAMPTZ NOT NULL DEFAULT now()
  created_at: TIMESTAMPTZ DEFAULT now()
}
```

### Critérios de Aceitação
- [ ] Câmera abre corretamente
- [ ] GPS captura localização automaticamente
- [ ] Envio com foto + localização funciona
- [ ] Dono recebe notificação push após avistamento
- [ ] Avistamento aparece no mapa e na lista do animal

---

## FEAT-07: Mapa de Avistamentos

### Descrição
Mapa interativo mostrando o local do desaparecimento e todos os avistamentos do animal.

### Fluxos
1. **Visualização**: Mapa centralizado no último avistamento (ou local do desaparecimento)
2. **Marcadores**: Pin vermelho = desaparecimento; Pins azuis = avistamentos
3. **Tap no marcador**: Exibe popup com data e foto miniatura
4. **Cluster**: Múltiplos avistamentos próximos agrupados em cluster

### Regras de Negócio
- Usa OpenStreetMap (tiles gratuitos)
- Zoom padrão ao nível de bairro (~15)
- Linha tracejada conecta os avistamentos em ordem cronológica

### Critérios de Aceitação
- [ ] Mapa carrega tiles do OpenStreetMap
- [ ] Marcadores posicionados corretamente
- [ ] Popup funciona ao tocar no marcador
- [ ] Linha tracejada entre avistamentos visível

---

## FEAT-08: Comentários

### Descrição
Usuários podem comentar nas publicações de animais perdidos.

### Modelos de Dados
```
comments {
  id: UUID (PK)
  pet_id: UUID NOT NULL REFS pets(id) ON DELETE CASCADE
  author_id: UUID NOT NULL REFS profiles(id)
  content: TEXT NOT NULL
  is_pinned: BOOLEAN DEFAULT false
  created_at: TIMESTAMPTZ DEFAULT now()
}
```

### Regras de Negócio
- Comentário máximo: 500 caracteres
- Apenas o dono do animal pode fixar comentários
- Comentários fixados aparecem sempre no topo
- Comentários não podem ser editados (apenas excluídos pelo próprio autor)

### Critérios de Aceitação
- [ ] Adicionar comentário funciona
- [ ] Comentários fixados aparecem no topo
- [ ] Autor pode excluir seu próprio comentário
- [ ] Dono pode fixar/desafixar comentários

---

## FEAT-09: Notificações Push

### Descrição
Sistema de notificações para manter o dono informado sobre seu animal.

### Tipos de Notificação
| Tipo | Gatilho | Destinatário |
|------|---------|--------------|
| `new_sighting` | Novo avistamento registrado | Dono do animal |
| `new_comment` | Novo comentário na publicação | Dono do animal |
| `pet_nearby` | Animal perdido cadastrado próximo ao usuário | Todos usuários da região |

### Modelos de Dados
```
notifications {
  id: UUID (PK)
  user_id: UUID NOT NULL REFS profiles(id)
  type: TEXT NOT NULL
  pet_id: UUID REFS pets(id)
  sighting_id: UUID REFS sightings(id)
  message: TEXT NOT NULL
  read: BOOLEAN DEFAULT false
  created_at: TIMESTAMPTZ DEFAULT now()
}
```

### Critérios de Aceitação
- [ ] Dono recebe push ao ter novo avistamento
- [ ] Dono recebe push ao ter novo comentário
- [ ] Push abre diretamente na tela relevante (deep link)
- [ ] Notificações exibidas na tela de notificações do app

---

## FEAT-10: Encerramento de Publicação

### Descrição
O dono pode alterar o status da publicação para `ENCONTRADO` ou `ENCERRADO`.

### Fluxos
1. **Encontrado**: Dono clica "Meu pet foi encontrado!" → Confirma → Status muda para `found` → Post celebratório aparece no feed
2. **Encerrar**: Dono clica "Encerrar busca" → Confirma motivo → Status muda para `closed`

### Regras de Negócio
- Apenas o dono pode alterar o status
- Ação é irreversível (não volta para `active`)
- Animais com status `found` ou `closed` não aparecem no feed principal
- Permanecem acessíveis via histórico do perfil do dono

### Critérios de Aceitação
- [ ] Botão disponível apenas para o dono
- [ ] Confirmação obrigatória antes de encerrar
- [ ] Status atualizado em tempo real para todos que têm a tela aberta
- [ ] Animal desaparece do feed após encerramento

---

## FEAT-11: Busca e Filtros

### Descrição
Busca textual e filtros avançados para encontrar animais perdidos específicos.

### Fluxos
1. **Busca Textual**: Por nome do animal, raça, cor ou descrição
2. **Filtros**: Espécie, porte, raio de distância
3. **Resultados**: Lista paginada com os mesmos cards do Feed

### Critérios de Aceitação
- [ ] Busca por nome retorna resultados relevantes
- [ ] Filtros combinados funcionam corretamente
- [ ] Estado vazio exibido quando sem resultados
- [ ] Busca rápida (debounce de 500ms no campo de texto)

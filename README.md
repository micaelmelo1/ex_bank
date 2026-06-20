# ExBank

API REST em Phoenix para gerenciamento de usuários e contas bancárias, com validação de CEP via [ViaCEP](https://viacep.com.br/) e autenticação por token Bearer.

## Tecnologias

- Elixir / Phoenix 1.8
- PostgreSQL
- Ecto
- Argon2 (hash de senha)
- Req (cliente HTTP)
- Phoenix.Token (autenticação)

## Pré-requisitos

- Elixir ~> 1.15
- PostgreSQL

## Configuração

```bash
mix setup
```

O comando instala as dependências, cria o banco e executa as migrations.

## Executando

```bash
mix phx.server
```

Ou dentro do IEx:

```bash
iex -S mix phx.server
```

A API fica disponível em [`http://localhost:4000`](http://localhost:4000).

## Autenticação

Alguns endpoints exigem o header `Authorization` com token Bearer obtido no login:

```
Authorization: Bearer <token>
```

**Rotas públicas** (não exigem token):

- `GET /api`
- `POST /api/users`
- `POST /api/users/login`

**Rotas protegidas** (exigem token):

- `GET /api/users/:id`
- `PUT /api/users/:id`
- `DELETE /api/users/:id`
- `POST /api/accounts`
- `POST /api/accounts/transaction`

## Endpoints

### `GET /api`

Retorna mensagem de boas-vindas.

```json
{ "message": "Welcome to ExBank API" }
```

### `POST /api/users`

Cria um usuário. O CEP é validado localmente e consultado na API ViaCEP antes da persistência.

**Body:**

```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "12345678",
  "zipcode": "01001000"
}
```

**Resposta `201`:**

```json
{
  "message": "User created successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "zipcode": "01001000"
  }
}
```

**Validações:**

- `name`, `email`, `password` e `zipcode` são obrigatórios
- `email` deve ter formato válido
- `password` deve ter no mínimo 8 caracteres
- `zipcode` deve ter exatamente 8 caracteres
- CEP deve existir na ViaCEP

### `POST /api/users/login`

Autentica um usuário e retorna um token Bearer.

**Body:**

```json
{
  "id": 1,
  "password": "12345678"
}
```

**Resposta `200`:**

```json
{
  "message": "Login successful",
  "bearer": "SFMyNTY..."
}
```

Use o valor de `bearer` no header `Authorization` das rotas protegidas.

### `GET /api/users/:id`

Retorna um usuário pelo ID. **Requer autenticação.**

**Resposta `200`:**

```json
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "zipcode": "01001000"
  }
}
```

### `PUT /api/users/:id`

Atualiza um usuário. A senha não é obrigatória na atualização. **Requer autenticação.**

**Body:**

```json
{
  "name": "Jane Doe",
  "email": "jane.doe@example.com",
  "zipcode": "01001000"
}
```

**Resposta `200`:**

```json
{
  "message": "User updated successfully",
  "data": {
    "id": 1,
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "zipcode": "01001000"
  }
}
```

### `DELETE /api/users/:id`

Remove um usuário pelo ID. **Requer autenticação.**

**Resposta `204`:**

```json
{
  "message": "User deleted successfully"
}
```

### `POST /api/accounts`

Cria uma conta bancária para um usuário. Cada usuário pode ter apenas uma conta. **Requer autenticação.**

**Body:**

```json
{
  "user_id": 1,
  "balance": "100.00"
}
```

**Resposta `201`:**

```json
{
  "message": "Account created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "balance": "100.00"
  }
}
```

**Validações:**

- `user_id` e `balance` são obrigatórios
- `user_id` deve existir
- `balance` deve ser maior ou igual a zero
- apenas uma conta por usuário

### `POST /api/accounts/transaction`

Transfere um valor entre duas contas de forma atômica. **Requer autenticação.**

**Body:**

```json
{
  "from_account_id": 1,
  "to_account_id": 2,
  "amount": "40.00"
}
```

**Resposta `200`:**

```json
{
  "message": "Transaction successful",
  "amount": "40.00",
  "from_account": {
    "id": 1,
    "user_id": 1,
    "balance": "60.00"
  },
  "to_account": {
    "id": 2,
    "user_id": 2,
    "balance": "140.00"
  }
}
```

**Validações:**

- contas de origem e destino devem existir
- `amount` deve ser um valor decimal válido
- conta de origem deve ter saldo suficiente

## Erros

| Status | Situação |
|--------|----------|
| `400` | Requisição inválida (ex.: parâmetros ausentes, amount inválido) |
| `401` | Não autenticado (token ausente, inválido ou credenciais incorretas no login) |
| `404` | Recurso não encontrado |
| `422` | Erros de validação do changeset |

Exemplo de erro de validação:

```json
{
  "errors": {
    "password": ["should be at least 8 character(s)"],
    "zipcode": ["should be 8 character(s)"]
  }
}
```

Exemplo de erro de autenticação:

```json
{
  "errors": {
    "detail": "Unauthorized"
  }
}
```

## Testes

```bash
mix test
```

Antes de commitar, execute o alias de verificação:

```bash
mix precommit
```

## Deploy

O projeto inclui configuração para deploy no [Fly.io](https://fly.io/) com Docker.

### Build local da imagem

```bash
docker build -t ex_bank .
```

### Deploy no Fly.io

```bash
fly deploy
```

As migrations são executadas automaticamente no deploy via `release_command` configurado no `fly.toml`.

### Variáveis de ambiente em produção

Configure no Fly.io (ou no `runtime.exs`):

- `DATABASE_URL` — conexão com o PostgreSQL
- `SECRET_KEY_BASE` — chave secreta da aplicação
- `PHX_HOST` — host público da API
- `PORT` — porta HTTP (padrão `8080` no Fly.io)

### CI/CD

O workflow em `.github/workflows/fly-deploy.yml` faz deploy automático no Fly.io a cada push na branch `master`. Configure o secret `FLY_API_TOKEN` no repositório GitHub.

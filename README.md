# ExBank

API REST em Phoenix para gerenciamento de usuários, com validação de CEP via [ViaCEP](https://viacep.com.br/).

## Tecnologias

- Elixir / Phoenix 1.8
- PostgreSQL
- Ecto
- Argon2 (hash de senha)
- Req (cliente HTTP)

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
    "id": "...",
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

### `GET /api/users/:id`

Retorna um usuário pelo ID.

**Resposta `200`:**

```json
{
  "data": {
    "id": "...",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "zipcode": "01001000"
  }
}
```

### `PUT /api/users/:id`

Atualiza um usuário. A senha não é obrigatória na atualização.

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
    "id": "...",
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "zipcode": "01001000"
  }
}
```

### `DELETE /api/users/:id`

Remove um usuário pelo ID.

**Resposta `204`:**

```json
{
  "message": "User deleted successfully"
}
```

## Erros

| Status | Situação |
|--------|----------|
| `400` | Requisição inválida (ex.: CEP malformado na ViaCEP) |
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

## Testes

```bash
mix test
```

Antes de commitar, execute o alias de verificação:

```bash
mix precommit
```

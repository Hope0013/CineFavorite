# 🎬 Documentação Técnica Completa: App CineFavorite


## 📁 Estrutura de Arquivos e Pastas

```text
lib/
├── models/
│   ├── movie_model.dart
│   └── user_model.dart
├── services/
│   ├── tmdb_service.dart
│   └── database_helper.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── movie_controller.dart
│   └── favorite_controller.dart
├── views/
│   ├── login_view.dart
│   ├── search_view.dart
│   ├── favorites_view.dart
│   └── movie_detail_view.dart
└── main.dart

```

---

## 🗃️ Estrutura do Banco de Dados (Postgres)

O banco de dados utilizará duas tabelas principais para atender a todos os requisitos de perfil de usuário e persistência de filmes favoritos.

### Tabela `user_profile`

Armazena o cadastro local do usuário logado.

| Coluna | Tipo SQL | Chave | Descrição |
| --- | --- | --- | --- |
| `id` | `INTEGER` | `PRIMARY KEY` | Identificador interno (fixo como `1`) |
| `name` | `TEXT` | - | Nome digitado no registro |
| `profile_image` | `TEXT` | - | Caminho local ou avatar selecionado |

### Tabela `favorites`

Armazena a galeria de filmes/séries salvos.

| Coluna | Tipo SQL | Chave | Descrição |
| --- | --- | --- | --- |
| `id` | `TEXT` | `PRIMARY KEY` | ID único retornado pelo TMDB |
| `title` | `TEXT` | - | Título do filme ou nome da série |
| `poster_path` | `TEXT` | - | Caminho da imagem retornado pela API |
| `rating` | `REAL` | - | Nota dada pelo usuário (ou nota do TMDB) |
| `media_type` | `TEXT` | - | Identifica se é `'movie'` ou `'tv'` |

### Criação de Tabelas

```sql
CREATE TABLE user_profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  profile_image TEXT NOT NULL
);

CREATE TABLE favorites (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  poster_path TEXT NOT NULL,
  rating REAL NOT NULL,
  media_type TEXT NOT NULL
);

```

## 📐 Diagrama de Classes e Arquitetura

```
classDiagram

    class UserModel {
        +int? id
        +String name
        +String profileImage
        +toMap() Map
        +fromMap() UserModel
    }

    class MovieModel {
        +String id
        +String title
        +String poster
        +double rating
        +String fullImageUrl
        +fromJson() MovieModel
        +toMap() Map
        +fromMap() MovieModel
    }

```

---

## ⚡ Fluxo de Telas (User Journey)

1. **Tela Login (`login_view.dart`)**:
* Campo de texto para o nome.
* Seleção de imagem de perfil (pode ser avatar padrão ou caminho da galeria).
* Botão "Entrar" que grava no SQLite e navega para a busca.


2. **Tela de Busca (`search_view.dart`)**:
* Campo `TextField` com ícone de lupa.
* `ListView.builder` exibindo os resultados retornados por `TMDBService.searchMovies()`.
* Ícone de "Coração" ao lado de cada item para adicionar/remover dos favoritos.


3. **Tela de Favoritos (`favorites_view.dart`)**:
* `GridView.builder` configurado com `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)` para exibir os cartazes em formato de grade.
* Botão de exclusão rápida em cada card.
* Opção de abrir um modal/dialog para editar a nota (`rating`).
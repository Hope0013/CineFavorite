class Movie {
  // Atributos
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final double? voteAverage;
  double rating;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    this.voteAverage,
    this.rating = 0.0,
  });

// Tratamento de dados vindos da API do TMDB
  factory Movie.fromTmdbJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      // A API do TMDB as vezes usa 'title' (filmes) e as vezes usa 'name' (séries). O uso do '??' garante que o app não quebre
      title: json['title'] ?? json['name'] ?? 'Sem Título',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'Sem sinopse disponível.',
      // APIs JSON as vezes mandam números inteiros em vez de decimais (8.0). Fazer o cast para 'num' antes de chamar '.toDouble()' previne erros
      voteAverage: json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : 0.0,
    );
  }

// Tratamento de dados vindos do Banco de Dados
  factory Movie.fromDbMap(Map<String, dynamic> map) {
    return Movie(
      id: map['movie_id'],
      title: map['title'],
      posterPath: map['poster_path'],
      overview: map['overview'] ?? 'Sem sinopse disponível.',
      voteAverage: map['vote_average'] != null ? (map['vote_average'] as num).toDouble() : 0.0,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : 0.0,
    );
  }
}
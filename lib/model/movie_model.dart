class Movie {
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

  factory Movie.fromTmdbJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Sem Título',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'Sem sinopse disponível.',
      voteAverage: json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : 0.0,
    );
  }

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
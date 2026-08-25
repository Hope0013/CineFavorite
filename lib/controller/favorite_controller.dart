import 'package:cine_favorite/model/movie_model.dart';
import '../services/database_helper.dart';

class FavoriteController {
  final dbHelper = DatabaseHelper();

  Future<List<Movie>> getFavorites(int userId) async {
    final conn = await dbHelper.connection;
    var results = await conn.mappedResultsQuery(
      'SELECT movie_id, title, poster_path, overview, vote_average, rating FROM favorites WHERE user_id = @userId',
      substitutionValues: {'userId': userId},
    );

    return results.map((row) => Movie.fromDbMap(row['favorites']!)).toList();
  }

  // Retorna verdadeiro se salvou, ou falso se já existia
  Future<bool> addFavorite(Movie movie, int userId) async {
    final conn = await dbHelper.connection;

    // Verifica se já está salvo no banco
    var check = await conn.query(
      'SELECT id FROM favorites WHERE user_id = @uid AND movie_id = @mid',
      substitutionValues: {'uid': userId, 'mid': movie.id},
    );

    if (check.isNotEmpty) {
      return false; // Já é favorito
    }

    await conn.query(
      'INSERT INTO favorites (user_id, movie_id, title, poster_path, overview, vote_average, rating) VALUES (@uid, @mid, @title, @poster, @overview, @vote, @rating)',
      substitutionValues: {
        'uid': userId,
        'mid': movie.id,
        'title': movie.title,
        'poster': movie.posterPath,
        'overview': movie.overview,
        'vote': movie.voteAverage,
        'rating': movie.rating,
      },
    );
    return true;
  }

  Future<void> removeFavorite(int movieId, int userId) async {
    final conn = await dbHelper.connection;
    await conn.query(
      'DELETE FROM favorites WHERE user_id = @uid AND movie_id = @mid',
      substitutionValues: {'uid': userId, 'mid': movieId},
    );
  }

  // Atualiza a nota atribuída pelo usuário
  Future<void> updateMovieRating(int movieId, int userId, double rating) async {
    final conn = await dbHelper.connection;
    await conn.query(
      'UPDATE favorites SET rating = @rating WHERE user_id = @uid AND movie_id = @mid',
      substitutionValues: {'rating': rating, 'uid': userId, 'mid': movieId},
    );
  }
}
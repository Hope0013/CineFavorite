import 'package:cine_favorite/model/movie_model.dart';
import '../services/tmdb_service.dart';

class MovieController {
  // Apenas chama o serviço da API e retorna a lista de filmes
  Future<List<Movie>> searchMovies(String query) async {
    return await TmdbService.searchMovies(query);
  }
}
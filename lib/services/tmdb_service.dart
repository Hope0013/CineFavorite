import 'dart:convert';
import 'package:cine_favorite/model/movie_model.dart';
import 'package:http/http.dart' as http;

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '5546b0d2a7c921ba49d9c2bfc4056c48'; 

  // Função para buscar filmes
  static Future<List<Movie>> searchMovies(String query) async {
    // Se a barra de pesquisa estiver vazia, encerra a função
    // Isso economiza "uso da internet" do usuário e requisições a API
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        
        // Mapeia a lista de JSON para uma lista de objetos Movie
        return results.map((json) => Movie.fromTmdbJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar filmes');
      }
    } catch (e) {
      print('Erro na API: $e');
      return [];
    }
  }

  // Gera a URL completa da imagem
  static String getImageUrl(String posterPath) {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
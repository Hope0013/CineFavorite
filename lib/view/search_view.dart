import 'package:cine_favorite/controller/favorite_controller.dart';
import 'package:cine_favorite/controller/movie_controller.dart';
import 'package:cine_favorite/model/movie_model.dart';
import 'package:cine_favorite/model/user_model.dart';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'favorites_view.dart';
import 'movie_view.dart';
import 'login_view.dart';

class SearchView extends StatefulWidget {
  final UserModel user;

  SearchView({required this.user});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final MovieController _movieController = MovieController();
  final FavoriteController _favoriteController = FavoriteController();

  List<Movie> _searchResults = [];
  Set<int> _favoriteMovieIds = {};
  bool _isLoading = false;
  String _statusMessage = 'Digite pelo menos 3 letras para buscar.';

  @override
  void initState() {
    super.initState();
    _loadFavoriteIds();
  }

  void _loadFavoriteIds() async {
    try {
      var favs = await _favoriteController.getFavorites(widget.user.id!);
      setState(() {
        _favoriteMovieIds = favs.map((m) => m.id).toSet();
      });
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  void _search(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _statusMessage = 'Digite pelo menos 3 letras para buscar.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      var results = await _movieController.searchMovies(query);
      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _statusMessage = 'Nenhum filme encontrado.';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro na busca. Verifique a conexão e sua chave TMDB.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(Movie movie) async {
    bool isFav = _favoriteMovieIds.contains(movie.id);

    if (isFav) {
      await _favoriteController.removeFavorite(movie.id, widget.user.id!);
      setState(() {
        _favoriteMovieIds.remove(movie.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${movie.title} removido dos favoritos!')),
      );
    } else {
      bool saved = await _favoriteController.addFavorite(movie, widget.user.id!);
      if (saved) {
        setState(() {
          _favoriteMovieIds.add(movie.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} salvo nos favoritos!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // Seta para voltar à tela de Login/Perfis
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginView()),
            );
          },
        ),
        title: Text('Buscar Filmes', style: TextStyle(color: Colors.red)),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesView(user: widget.user),
                ),
              );
              _loadFavoriteIds();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do filme...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                suffixIcon: Icon(Icons.search, color: Colors.red),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.red))
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final movie = _searchResults[index];
                          final isFavorited = _favoriteMovieIds.contains(movie.id);

                          return ListTile(
                            leading: movie.posterPath != null
                                ? Image.network(TmdbService.getImageUrl(movie.posterPath!))
                                : Icon(Icons.movie, color: Colors.grey),
                            title: Text(movie.title, style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              'Nota TMDB: ${movie.voteAverage?.toStringAsFixed(1) ?? "N/A"}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieView(movie: movie, user: widget.user),
                                ),
                              );
                              _loadFavoriteIds();
                            },
                            trailing: IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () => _toggleFavorite(movie),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
import 'package:cine_favorite/controller/favorite_controller.dart';
import 'package:cine_favorite/model/movie_model.dart';
import 'package:cine_favorite/model/user_model.dart';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'movie_view.dart';

class FavoritesView extends StatefulWidget {
  final UserModel user;

  FavoritesView({required this.user});

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final FavoriteController _favoriteController = FavoriteController();
  List<Movie> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    var list = await _favoriteController.getFavorites(widget.user.id!);

    setState(() {
      _favorites = list;
      _isLoading = false;
    });
  }

  void _removeFavorite(int movieId) async {
    await _favoriteController.removeFavorite(movieId, widget.user.id!);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Meus Favoritos', style: TextStyle(color: Colors.red)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : _favorites.isEmpty
              ? Center(child: Text('Nenhum favorito.', style: TextStyle(color: Colors.white)))
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final movie = _favorites[index];
                    return GestureDetector(
                      // Ao clicar no card, abre a tela do filme
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieView(movie: movie, user: widget.user),
                          ),
                        );
                        _loadFavorites(); // Recarrega ao voltar para atualizar a nota
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  movie.posterPath != null
                                      ? TmdbService.getImageUrl(movie.posterPath!)
                                      : 'https://via.placeholder.com/150',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // Barra inferior com título e avaliação do usuário
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    movie.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        '${movie.rating.toInt()}/5',
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Botão de remover dos favoritos
                          Positioned(
                            top: 5,
                            right: 5,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFavorite(movie.id),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
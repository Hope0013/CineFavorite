import 'package:cine_favorite/controller/favorite_controller.dart';
import 'package:cine_favorite/model/movie_model.dart';
import 'package:cine_favorite/model/user_model.dart';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class MovieView extends StatefulWidget {
  final Movie movie;
  final UserModel user;

  MovieView({required this.movie, required this.user});

  @override
  _MovieViewState createState() => _MovieViewState();
}

class _MovieViewState extends State<MovieView> {
  final FavoriteController _favoriteController = FavoriteController();
  late double _userRating;
  bool _isSaving = false;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _userRating = widget.movie.rating > 5.0 ? 5.0 : widget.movie.rating;
    _checkIfFavorited();
  }

  void _checkIfFavorited() async {
    var favs = await _favoriteController.getFavorites(widget.user.id!);
    var found = favs.firstWhere(
      (m) => m.id == widget.movie.id,
      orElse: () => Movie(id: -1, title: ''),
    );

    if (found.id != -1) {
      setState(() {
        _isFavorited = true;
        if (found.rating > 0) {
          _userRating = found.rating;
        }
      });
    }
  }

  void _toggleFavorite() async {
    if (_isFavorited) {
      await _favoriteController.removeFavorite(widget.movie.id, widget.user.id!);
      setState(() {
        _isFavorited = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removido dos favoritos!')),
      );
    } else {
      await _favoriteController.addFavorite(widget.movie, widget.user.id!);
      if (_userRating > 0) {
        await _favoriteController.updateMovieRating(widget.movie.id, widget.user.id!, _userRating);
      }
      setState(() {
        _isFavorited = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicionado aos favoritos!')),
      );
    }
  }

  void _saveRating() async {
    if (!_isFavorited) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorite o filme primeiro para salvar sua avaliação!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _favoriteController.updateMovieRating(widget.movie.id, widget.user.id!, _userRating);

      setState(() {
        widget.movie.rating = _userRating;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avaliação de ${_userRating.toInt()} estrelas salva!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar avaliação.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.movie.title, style: TextStyle(color: Colors.red)),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.movie.posterPath != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    TmdbService.getImageUrl(widget.movie.posterPath!),
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            Text(
              widget.movie.title,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 5),
                Text(
                  'Média TMDB: ${widget.movie.voteAverage?.toStringAsFixed(1) ?? "N/A"}',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Sinopse',
              style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.movie.overview ?? 'Sem sinopse disponível.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 30),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 10),
            Text(
              'Sua Avaliação: ${_userRating.toInt()} / 5 ★',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  iconSize: 36,
                  icon: Icon(
                    starValue <= _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _userRating = starValue.toDouble();
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            Center(
              child: _isSaving
                  ? CircularProgressIndicator(color: Colors.red)
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _saveRating,
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text('Salvar Nota', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
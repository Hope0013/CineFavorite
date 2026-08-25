import 'package:cine_favorite/view/login_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CineFavoriteApp());
}

class CineFavoriteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineFavorite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginView(),
    );
  }
}
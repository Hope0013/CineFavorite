import 'package:cine_favorite/model/user_model.dart';
import '../services/database_helper.dart';

class AuthController {
  final dbHelper = DatabaseHelper();

  Future<List<UserModel>> getAllUsers() async {
    final conn = await dbHelper.connection;
    var results = await conn.mappedResultsQuery(
      'SELECT id, name, profile_pic FROM users',
    );

    List<UserModel> users = [];
    for (var row in results) {
      // mappedResultsQuery retorna os dados agrupados pelo nome da tabela.
      // Por isso é necessário acessar row['users'] antes de extrair os campos.
      var userMap = Map<String, dynamic>.from(row['users']!);
      users.add(UserModel.fromDbMap(userMap));
    }

    return users;
  }

  Future<UserModel> login(String name, String profilePic) async {
    final conn = await dbHelper.connection;

    var result = await conn.mappedResultsQuery(
      'SELECT id, name, profile_pic FROM users WHERE name = @name',
      substitutionValues: {'name': name},
    );

    // Lógica de "login ou registro" automático:
    // Se o usuário existir (isNotEmpty), retorna o cadastro existente.

    if (result.isNotEmpty) {
      var userMap = Map<String, dynamic>.from(result.first['users']!);
      return UserModel.fromDbMap(userMap);
    } else {
      // Se não existir, insere o novo usuário no banco e usa o returning
      // para devolver os dados criados (incluindo o ID gerado) na mesma requisição.
      var insertResult = await conn.mappedResultsQuery(
        'INSERT INTO users (name, profile_pic) VALUES (@name, @pic) RETURNING id, name, profile_pic',
        substitutionValues: {'name': name, 'pic': profilePic},
      );
      var userMap = Map<String, dynamic>.from(insertResult.first['users']!);
      return UserModel.fromDbMap(userMap);
    }
  }

  // Deleta o usuário do banco de dados (e os favoritos associados via CASCADE)
  Future<void> deleteUser(int userId) async {
    final conn = await dbHelper.connection;
    await conn.query(
      'DELETE FROM users WHERE id = @id',
      substitutionValues: {'id': userId},
    );
  }
}
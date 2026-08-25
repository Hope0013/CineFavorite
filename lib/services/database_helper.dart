import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final String dbHost = '10.0.2.2';
  final int port = 5432;
  final String dbName = 'cinefavorite';
  final String dbUser = 'postgres';
  final String dbPassword = 'postgres';

  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }
    _connection = PostgreSQLConnection(
      dbHost,
      port,
      dbName,
      username: dbUser,
      password: dbPassword,
    );
    await _connection!.open();
    return _connection!;
  }
}
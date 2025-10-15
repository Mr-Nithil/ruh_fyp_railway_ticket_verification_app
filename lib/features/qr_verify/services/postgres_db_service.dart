import 'package:postgres/postgres.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/config/db_config.dart';

class PostgresDbService {
  Connection? _connection;

  /// Connect to the PostgreSQL database
  Future<Connection> connect() async {
    // If already connected, return existing connection
    if (_connection != null) {
      print('♻️ Reusing existing connection');
      return _connection!;
    }

    // Open new connection to Heroku Postgres
    _connection = await Connection.open(
      Endpoint(
        host: DbConfig.host,
        database: DbConfig.database,
        username: DbConfig.username,
        password: DbConfig.password,
        port: DbConfig.port,
      ),
      settings: ConnectionSettings(
        sslMode: SslMode
            .require, // Use 'require' instead of 'verifyFull' to avoid certificate verification issues
      ),
    );

    print('✅ Connected to Database!');
    return _connection!;
  }

  /// Close the database connection
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('🔒 Connection closed');
    } else {
      print('⚠️ No active connection to close');
    }
  }

  /// Check if currently connected
  bool get isConnected => _connection != null;

  /// Get the current connection (throws if not connected)
  Connection get connection {
    if (_connection == null) {
      throw StateError('Database not connected. Call connect() first.');
    }
    return _connection!;
  }
}

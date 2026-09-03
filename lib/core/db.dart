import 'package:postgres/postgres.dart';
import 'config.dart';

class PosDb {
  PosDb._();
  static final PosDb instance = PosDb._();
  Connection? _connection;
  Future<Connection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await Connection.open(Endpoint(host: PosConfig.host, port: PosConfig.port, database: PosConfig.database, username: PosConfig.username, password: PosConfig.password), settings: const ConnectionSettings(sslMode: SslMode.disable));
    return _connection!;
  }
  Future<void> close() async { await _connection?.close(); _connection = null; }
}

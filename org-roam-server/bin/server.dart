import 'dart:io';
import 'package:server/server.dart';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> arguments) async {
  final uiPort = int.parse(Platform.environment['UI_PORT'] ?? '8080');
  final sqlLibPath = Platform.environment['SQLITE_LIBRARY_PATH'] ??
      '/usr/lib/x86_64-linux-gnu/libsqlite3.so';
  final neuronPath =
      Platform.environment['NEURON_PATH']?.trailingComma() ?? '/Neuron';
  final originalDirectoryPath =
      Platform.environment['ORIGINAL_DIRECTORY_PATH']?.trailingComma() ??
          '/home/dhaval/Hive/Realm/Neuron';
  final dbPath = Platform.environment['DB_PATH'] ?? '$neuronPath/neuron.db';
  final publicPath = Platform.environment['PUBLIC_PATH'] ?? '/public';
  print('''
Sqlite library :$sqlLibPath
Sqlite version: ${sqlite3.version}
Org-roam database: $dbPath
Org-roam-ui public dir: $publicPath''');
  final api = SqlApi(dbPath: dbPath, sqlLibPath: sqlLibPath);
  final graph = await api.fetch();
  final frontEnd = FrontEndServer(
    port: uiPort,
    graph: graph,
    publicPath: publicPath,
    pathTransformer: (path) =>
        path.replaceFirst(originalDirectoryPath, neuronPath),
  );
  await frontEnd.init();
  print('''
Creating server
Serving at http://localhost:$uiPort''');
}

extension on String {
  String trailingComma() => this.endsWith('/') ? this : (this + '/');
}

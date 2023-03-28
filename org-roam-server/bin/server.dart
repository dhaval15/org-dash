import 'dart:convert';
import 'dart:io';
import 'package:server/server.dart';
import 'package:server/src/models/neuron_options.dart';
import 'package:server/src/models/neuron.dart';
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
  final neuron = await api.fetch();
  final context = NeuronRouterContext(
    neuron: neuron,
    pathTransformer: (String path) =>
        path.replaceFirst(originalDirectoryPath, neuronPath),
  );
  final backEnd = NeuronServer(
    port: uiPort,
    vueRouter: VueRouter(publicPath),
    apiRouter: ApiRouter(context),
  );
  await backEnd.init();
  RegexpExpression.pathTransformer = context.pathTransformer;
  print('''
Creating server
Serving at http://localhost:$uiPort''');
}

class NeuronRouterContext with RouterContext {
  @override
  NeuronOptions options = NeuronOptions.defaultOptions;

  @override
  final JsonEncoder encoder = JsonEncoder();

  final Neuron neuron;

  @override
  final String Function(String path) pathTransformer;

  NeuronRouterContext({
    required this.neuron,
    required this.pathTransformer,
  });

  @override
  String transformPath(String path) {
    return pathTransformer(path);
  }
}

class FileLogger extends Logger {
  const FileLogger();

  void call(String message, bool isError) async {
    final file = File('orglogs.txt');
    if (isError) {
      file.writeAsString(message);
    }
  }
}

extension on String {
  String trailingComma() => this.endsWith('/') ? this : (this + '/');
}

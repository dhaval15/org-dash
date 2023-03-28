import 'dart:convert';
import 'dart:io';
import 'package:server/server.dart';
import 'package:server/src/env/env.dart';
import 'package:server/src/models/neuron_options.dart';
import 'package:server/src/models/neuron.dart';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> arguments) async {
  final env = Env.fromPlatform();
  print('''
Sqlite library :${env.sqlLibPath}
Sqlite version: ${sqlite3.version}
Org-roam database: ${env.dbPath}
Org-roam-ui public dir: ${env.publicPath}''');
  final api = SqlApi(dbPath: env.dbPath, sqlLibPath: env.sqlLibPath);
  final neuron = await api.fetch();
  final context = NeuronRouterContext(
    neuron: neuron,
    pathTransformer: (String path) =>
        path.replaceFirst(env.originalDirectoryPath, env.neuronPath),
  );
  final backEnd = NeuronServer(
    port: env.uiPort,
    vueRouter: VueRouter(env.publicPath),
    apiRouter: ApiRouter(context),
    logger: FileLogger(),
  );
  await backEnd.init();
  RegexpExpression.pathTransformer = context.pathTransformer;
  print('''
Creating server
Serving at http://localhost:${env.uiPort}''');
}

class NeuronRouterContext with RouterContext {
	@override
	ScopeApi get scopeApi => DummyScopeApi();

  @override
  NeuronOptions options = NeuronOptions.defaultOptions;

  @override
  final JsonEncoder encoder = JsonEncoder();

  final Neuron neuron;

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

class DummyScopeApi extends ScopeApi {
  @override
  Future<List<Scope>> fetch() async {
    return [
			Scope(
				id: '1',
				label: 'Coding Space',
				expr: '(space "Code")',
			),
			Scope(
				id: '2',
				label: 'Coding Space',
				expr: '(regex "Father")',
			),
		];
  }

  @override
  Future insert(Scope scope) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future remove(String id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future update(Scope scope) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

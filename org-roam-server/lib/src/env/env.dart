import 'dart:io';

class Env {
  final int uiPort;
  final String sqlLibPath;
  final String neuronPath;
  final String originalDirectoryPath;
  final String dbPath;
  final String publicPath;

  const Env({
    required this.uiPort,
    required this.sqlLibPath,
    required this.neuronPath,
    required this.originalDirectoryPath,
    required this.dbPath,
    required this.publicPath,
  });

  factory Env.fromPlatform() {
    final neuronPath =
        Platform.environment['NEURON_PATH']?.trailingComma() ?? '/Neuron';
    return Env(
      uiPort: int.parse(Platform.environment['UI_PORT'] ?? '8080'),
      sqlLibPath: Platform.environment['SQLITE_LIBRARY_PATH'] ??
          '/usr/lib/x86_64-linux-gnu/libsqlite3.so',
      neuronPath: neuronPath,
      originalDirectoryPath:
          Platform.environment['ORIGINAL_DIRECTORY_PATH']?.trailingComma() ??
              '/home/dhaval/Hive/Realm/Neuron',
      dbPath: Platform.environment['DB_PATH'] ?? '$neuronPath/neuron.db',
      publicPath: Platform.environment['PUBLIC_PATH'] ?? '/public',
    );
  }
}

extension on String {
  String trailingComma() => this.endsWith('/') ? this : (this + '/');
}

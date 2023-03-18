import 'dart:convert';
import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'models.dart';

class SqlApi {
  final String dbPath;
  final String sqlLibPath;

  const SqlApi({
    required this.dbPath,
    required this.sqlLibPath,
  });

  Future<Graph> fetch() async {
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
    final db = sqlite3.open(dbPath);
    final nodesResult = db.select('SELECT * FROM nodes;');
    final linksResult = db.select('SELECT * FROM links;');
    final tagsResult = db.select('SELECT * FROM tags;');
    db.dispose();
    return Graph(
      nodes: _fetchNodes(nodesResult),
      links: _fetchLinks(linksResult),
      tags: _fetchTags(tagsResult),
    );
  }

  List<Node> _fetchNodes(ResultSet result) {
    final nodes = <Node>[];
    for (final row in result) {
      final map = Map<String, dynamic>.from(row);
      map['properties'] =
          JsonDecoder().convert(elispMapToJsonText(map['properties']));
      if (map['olp'] != null)
        map['olp'] = JsonDecoder().convert(elispListToJsonText(map['olp']));
      final node = Node.fromJson(map);
      nodes.add(node);
    }
    return nodes;
  }

  List<Link> _fetchLinks(ResultSet result) {
    final links = <Link>[];
    for (final row in result) {
      final map = Map<String, dynamic>.from(row);
      final link = Link.fromJson(map);
      links.add(link);
    }
    return links;
  }

  List<String> _fetchTags(ResultSet result) {
    return result.map((e) => e['tag']).toSet().toList().cast<String>();
  }

  DynamicLibrary _openOnLinux() {
    return DynamicLibrary.open(sqlLibPath);
  }
}

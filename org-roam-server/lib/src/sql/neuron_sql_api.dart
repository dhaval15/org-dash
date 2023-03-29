import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/models.dart';

class NeuronSqlApi {
  final Database _db;
  final String Function(String path) pathTransformer;

  const NeuronSqlApi(this._db, this.pathTransformer);

  static Future<NeuronSqlApi> create({
    required String dbPath,
    required String sqlLibPath,
    required String Function(String path) pathTransformer,
  }) async {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open(sqlLibPath);
    });
    final db = sqlite3.open(dbPath);
    return NeuronSqlApi(db, pathTransformer);
  }

  void dispose() {
    _db.dispose();
  }

  Neuron get neuron {
    return Neuron(
      nodes: nodes,
      links: links,
      tags: tags,
    );
  }

  List<Link> get links {
    final query = 'SELECT * FROM links;';
    final response = _db.select(query);
    return response.map(Link.fromJson).toList();
  }

  List<String> get tags {
    final query = 'SELECT DISTINCT tag FROM tags;';
    final response = _db.select(query);
    return response.map((e) => e['tag'] as String).toList();
  }

  List<Node> get nodes {
    final query = '''
SELECT 
	n.*, 
	(SELECT GROUP_CONCAT(t.tag) FROM tags t
		WHERE t.node_id = n.id
		GROUP BY t.node_id) as tags
	FROM nodes n;
''';
    final response = _db.select(query);
    return response.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['file'] = pathTransformer(map['file']);
      map['properties'] =
          JsonDecoder().convert(elispMapToJsonText(map['properties']));
      if (map['olp'] != null)
        map['olp'] = JsonDecoder().convert(elispListToJsonText(map['olp']));
      map['tags'] = _Utils.parseTags(map['tags']);
      return Node.fromJson(map);
    }).toList();
  }

  List<String> findTagsForNodeId(String id) {
    final query = '''
SELECT 
	GROUP_CONCAT(tag) as tags 
	FROM tags 
	WHERE node_id=\'"$id"\' 
	GROUP BY node_id;
''';
    final response = _db.select(query);
    return _Utils.parseTags(response.first['tags']);
  }

  List<Link> findLinksForNodeId(String id, [String? file]) {
    final query = '''
SELECT * 
	FROM links 
	WHERE 
		source=\'"$id"\' OR dest=\'"$id"\';
''';
    final response = _db.select(query);
    return response.map((e) {
      final map = Map<String, dynamic>.from(e);
      if (file != null)
        map['inline'] = _Utils.parseInlineText(file, map['pos']);
      return Link.fromJson(map);
    }).toList();
  }

  Node findNode(String id) {
    final query = '''
SELECT 
		n.*, 
		(SELECT GROUP_CONCAT(t.tag) FROM tags t
				WHERE t.node_id = n.id
				GROUP BY t.node_id) as tags
		FROM nodes n
		WHERE n.id=\'"$id"\'
''';
    final response = _db.select(query);
    final map = Map<String, dynamic>.from(response.first);
    map['file'] = pathTransformer(map['file']);
    map['properties'] =
        JsonDecoder().convert(elispMapToJsonText(map['properties']));
    if (map['olp'] != null)
      map['olp'] = JsonDecoder().convert(elispListToJsonText(map['olp']));
		print(map);
    map['tags'] = _Utils.parseTags(map['tags']);
    map['incoming'] = findLinksForNodeId(id, trimQuotes(map['file']));
    return Node.fromJson(map);
  }
}

class _Utils {
  static List<String> parseTags(String? text) =>
      text?.split(',').map(trimQuotes).toList() ?? [];

  static String? parseInlineText(String path, int pos) {
    final file = File(path);
    final rf = file.openSync();
    rf.setPositionSync(pos);
    final inline = _readLink(rf);
    final regex = RegExp('\\[\\[(.*)\\]\\[(.*)\\]\\]');
    final match = regex.firstMatch(inline);
    return match?.group(2);
  }

  static String _readLink(RandomAccessFile file) {
    final buffer = StringBuffer();
    String c = String.fromCharCode(file.readByteSync());
    String im = ' $c';
    while (true) {
      c = String.fromCharCode(file.readByteSync());
      buffer.write(c);
      im = im[1] + c;
      if (im == '[[') {
        buffer.clear();
        buffer.write('[[');
      }
      if (im == ']]') {
        return buffer.toString().replaceAll('\n', ' ');
      }
    }
  }
}

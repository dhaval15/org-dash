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
    final query = '''
SELECT 
	${_Utils.trimQuotesQuery('l', 'type')},
	${_Utils.trimQuotesQuery('l', 'source')},
	${_Utils.trimQuotesQuery('l', 'dest', 'target')},
	l.pos
FROM links l;''';
    final response = _db.select(query);
    return response.map(Link.fromJson).toList();
  }

  List<String> get tags {
    final query = '''
SELECT 
	SUBSTRING(DISTINCT(tag), 2, LENGTH(tag) - 2) 
		as tag 
	FROM tags;
''';
    final response = _db.select(query);
    return response.map((e) => e['tag'] as String).toList();
  }

  List<Node> get nodes {
    final query = '''
SELECT 
	n.*,
	${_Utils.trimQuotesQuery('n', 'id')},
	${_Utils.trimQuotesQuery('n', 'title')},
	${_Utils.trimQuotesQuery('n', 'file')}
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
      return Node.fromJson(map);
    }).toList();
  }

  List<String> findTagsForNodeId(String id) {
    final query = '''
SELECT 
	GROUP_CONCAT(SUBSTRING(tag, 2, tag.length - 2)) as tags 
	FROM tags 
	WHERE node_id=\'"$id"\' 
	GROUP BY node_id;
''';
    final response = _db.select(query);
    return response.first['tags'].split(',');
  }

  List<Link> findLinksForNodeId(String id) {
    final query = '''
SELECT 
	${_Utils.trimQuotesQuery('l', 'type')},
	${_Utils.trimQuotesQuery('l', 'source')},
	${_Utils.trimQuotesQuery('l', 'dest', 'target')},
	l.pos,
	(SELECT 
		${_Utils.trimQuotesQuery('n', 'file')}
		FROM nodes n 
		WHERE n.id = l.source) as file,
	(SELECT 
		${_Utils.trimQuotesQuery('n', 'title')}
		FROM nodes n 
		WHERE n.id = l.source) as sourceLabel,
	(SELECT 
		${_Utils.trimQuotesQuery('n', 'title')}
		FROM nodes n 
		WHERE n.id = l.dest) as targetLabel
	FROM links l
	WHERE 
		l.source=\'"$id"\' OR l.dest=\'"$id"\';
''';
    final response = _db.select(query);
    return response.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['file'] = pathTransformer(map['file']);
      map['inline'] = _Utils.parseInlineText(map['file'], map['pos']);
      return Link.fromJson(map);
    }).toList();
  }

  Node findNode(String id) {
    final query = '''
SELECT 
	n.*, 
	${_Utils.trimQuotesQuery('n', 'id')},
	${_Utils.trimQuotesQuery('n', 'title')},
	${_Utils.trimQuotesQuery('n', 'file')}
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
    map['links'] = findLinksForNodeId(id);
    return Node.fromJson(map);
  }
}

class _Utils {
  static String trimQuotesQuery(String table, String column,
          [String? asColumn]) =>
      'SUBSTRING($table.$column, 2, LENGTH($table.$column) - 2) as ${asColumn ?? column}';

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

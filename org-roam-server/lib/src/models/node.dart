import 'utils.dart';
import 'node_properties.dart';
class Node {
  final String id;
  final List<String> tags;
  final NodeProperties properties;
  final List<String>? olp;
  final int pos;
  final int level;
  final String title;
  final String file;

	String get type => properties.type ?? 'None';
	String get genre => properties.genre ?? 'None';
	String get space => properties.space ?? 'None';

  const Node({
    required this.id,
    required this.tags,
    required this.properties,
    this.olp,
    required this.pos,
    required this.level,
    required this.title,
    required this.file,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] != null
        ? (List<String?>.from(json['tags'])..removeWhere((e) => e == null))
        : [];
    return Node(
      id: trimQuotes(json['id']),
      properties: NodeProperties.fromJson(json['properties']),
      tags: tags.cast<String>(),
      olp: json['olp']?.cast<String>(),
      pos: json['pos'],
      level: json['level'],
      title: trimQuotes(json['title']),
      file: trimQuotes(json['file']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tags': tags,
        'properties': properties.toJson(),
        'olp': olp,
        'pos': pos,
        'level': level,
        'title': title,
      };
}

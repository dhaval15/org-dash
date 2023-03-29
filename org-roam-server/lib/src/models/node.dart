import 'link.dart';
class Node {
  final String id;
  final List<String> tags;
  final Map<String,dynamic> properties;
  final List<String>? olp;
  final int pos;
  final int level;
  final String title;
  final String file;
  final List<Link> links;

	String get type => properties['NEURON_TYPE'] ?? 'None';
	String get genre => properties['NEURON_GENRE'] ?? 'None';
	String get space => properties['NEURON_SPACE'] ?? 'None';

  const Node({
    required this.id,
    required this.tags,
    required this.properties,
    this.olp,
    required this.pos,
    required this.level,
    required this.title,
    required this.file,
		required this.links,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
		final tags = json['tags'] != null
        ? (List<String?>.from(json['tags'])..removeWhere((e) => e == null))
        : <String>[];
    return Node(
      id: json['id'],
      properties: json['properties'],
      tags: tags as List<String>,
      olp: json['olp']?.cast<String>(),
      pos: json['pos'],
      level: json['level'],
      title: json['title'],
      file: json['file'],
			links: json['links'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tags': tags,
        'properties': properties,
        'olp': olp,
        'pos': pos,
        'level': level,
        'title': title,
        'links': links.map((e) => e.toJson()).toList(),
      };
}

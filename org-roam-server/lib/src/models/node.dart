import 'link.dart';
import 'utils.dart';
class Node {
  final String id;
  final List<String> tags;
  final Map<String,dynamic> properties;
  final List<String>? olp;
  final int pos;
  final int level;
  final String title;
  final String file;

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
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: trimQuotes(json['id']),
      properties: json['properties'],
      tags: json['tags']?.split(',') ?? [],
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
        'properties': properties,
        'olp': olp,
        'pos': pos,
        'level': level,
        'title': title,
      };
}

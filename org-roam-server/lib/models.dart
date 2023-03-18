class Graph {
  final List<Node> nodes;
  final List<Link> links;
  final List<String> tags;

  const Graph({
    required this.nodes,
    required this.links,
    required this.tags,
  });

  factory Graph.fromJson(Map<String, dynamic> json) => Graph(
        nodes: json['nodes'].map((e) => Node.fromJson(e)).toList().cast<Node>(),
        links: json['links'].map((e) => Link.fromJson(e)).toList().cast<Link>(),
        tags: json['tags'].cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'links': links.map((link) => link.toJson()).toList(),
        'tags': tags,
      };
}

class Node {
  final String id;
  final List<String> tags;
  final Properties properties;
  final List<String>? olp;
  final int pos;
  final int level;
  final String title;
  final String file;

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
      properties: Properties.fromJson(json['properties']),
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

class Properties {
  final String? category;
  final String? genre;
  final String? type;
  final String id;
  final String blocked;
  final String file;
  final String priority;

  const Properties({
    this.category,
    this.genre,
    this.type,
    required this.id,
    required this.blocked,
    required this.file,
    required this.priority,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        category: json['CATEGORY'],
        genre: json['NEURON_GENRE'],
        type: json['NEURON_TYPE'],
        id: json['id'] ?? json['ID'],
        blocked: json['BLOCKED'],
        file: json['FILE'],
        priority: json['PRIORITY'],
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'genre': genre,
        'type': type,
        'id': id,
        'blocked': blocked,
        'file': file,
        'priority': priority,
      };
}

class Link {
  final String type;
  final String target;
  final String source;

  const Link({
    required this.type,
    required this.target,
    required this.source,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        type: trimQuotes(json['type']),
        target: trimQuotes(json['dest']),
        source: trimQuotes(json['source']),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'target': target,
        'source': source,
      };
}

String elispMapToJsonText(String text) => text
    .replaceAll('" . "', '" : "')
    .replaceAll(') (', ',')
    .replaceAll('((', '{')
    .replaceAll('))', '}');

String elispListToJsonText(String text) =>
    text.replaceAll('(', '[').replaceAll(')', ']');

String trimQuotes(String text) => text.substring(1, text.length - 1);

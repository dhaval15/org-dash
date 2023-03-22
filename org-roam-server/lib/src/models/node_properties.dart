class NodeProperties {
  final String? category;
  final String? genre;
  final String? space;
  final String? type;
  final String id;
  final String blocked;
  final String file;
  final String priority;

  const NodeProperties({
    this.category,
    this.genre,
    this.type,
    this.space,
    required this.id,
    required this.blocked,
    required this.file,
    required this.priority,
  });

  factory NodeProperties.fromJson(Map<String, dynamic> json) => NodeProperties(
        category: json['CATEGORY'],
        genre: json['NEURON_GENRE'],
        type: json['NEURON_TYPE'],
        space: json['NEURON_SPACE'],
        id: json['id'] ?? json['ID'],
        blocked: json['BLOCKED'],
        file: json['FILE'],
        priority: json['PRIORITY'],
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'genre': genre,
        'type': type,
        'space': space,
        'id': id,
        'blocked': blocked,
        'file': file,
        'priority': priority,
      };
}

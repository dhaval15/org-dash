import 'utils.dart';
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

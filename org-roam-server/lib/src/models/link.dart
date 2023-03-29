import 'utils.dart';
class Link {
	final int pos;
  final String type;
  final String target;
  final String source;
	final String? inline;

  const Link({
    required this.type,
    required this.target,
    required this.source,
		required this.pos,
		this.inline,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        type: trimQuotes(json['type']),
        target: trimQuotes(json['dest']),
        source: trimQuotes(json['source']),
        pos: json['pos'],
				inline: json['inline'], 
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'target': target,
        'source': source,
        'pos': pos,
      };
}

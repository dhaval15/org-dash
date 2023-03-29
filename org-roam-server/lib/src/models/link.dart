class Link {
	final int pos;
  final String type;
  final String target;
  final String source;
  final String? file;
	final String? inline;
	final String? targetLabel;
	final String? sourceLabel;

  const Link({
    required this.type,
    required this.target,
    required this.source,
		required this.pos,
    this.file,
		this.inline,
		this.targetLabel,
		this.sourceLabel,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        type: json['type'],
        target: json['target'],
        source: json['source'],
        pos: json['pos'],
				inline: json['inline'], 
				file: json['file'], 
				sourceLabel: json['sourceLabel'], 
				targetLabel: json['targetLabel'], 
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'target': target,
        'source': source,
        'pos': pos,
        'inline': inline,
        'sourceLabel': sourceLabel,
        'targetLabel': targetLabel,
        'file': file,
      };
}

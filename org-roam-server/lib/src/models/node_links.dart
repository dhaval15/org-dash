
class NodeLinks {
  final List<LinkRef> from;
  final List<LinkRef> to;

  const NodeLinks(this.from, this.to);

  Map<String, dynamic> toJson() => {
        'from': from.map((e) => e.toJson()).toList(),
        'to': to.map((e) => e.toJson()).toList(),
      };
}

class LinkRef {
  final String title;
  final String id;

  const LinkRef(this.id, this.title);

  Map<String, String> toJson() => {
        'title': title,
        'id': id,
      };
}


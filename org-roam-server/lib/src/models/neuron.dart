import 'link.dart';
import 'node.dart';

class Neuron {
  final List<Node> nodes;
  final List<Link> links;
  final List<String> tags;

  const Neuron({
    required this.nodes,
    required this.links,
    required this.tags,
  });

  factory Neuron.fromJson(Map<String, dynamic> json) => Neuron(
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

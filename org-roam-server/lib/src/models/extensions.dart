import '../expr/expr.dart';
import 'neuron.dart';
import 'neuron_options.dart';
import 'node.dart';
import 'node_links.dart';

extension NeuronExtension on Neuron {
  Future<Neuron> expr(Expression expression) async {
    final newNodes = <Node>[];
    for (final node in nodes) {
      if (await expression.evaluate(node)) {
        newNodes.add(node);
      }
    }
    final newNodeIds = nodes.map((node) => node.id).toList();
    final newLinks = links
        .where((link) =>
            newNodeIds.contains(link.source) &&
            newNodeIds.contains(link.target))
        .toList();
    final newTags =
        nodes.fold<Set<String>>({}, (prev, node) => prev..addAll(node.tags));
    return Neuron(
      nodes: newNodes,
      links: newLinks,
      tags: newTags.toList(),
    );
  }

  Neuron transform(NeuronOptions options) {
    if (options.insertGhostNodes) {
      //TODO insert ghost nodes
      return this;
    } else {
      final ids = nodes.map((node) => node.id).toList();
      return Neuron(
        nodes: nodes,
        tags: tags,
        links: links.where((link) => !ids.contains(link.target)).toList(),
      );
    }
  }

  Node? findNode(String id) {
    try {
      return nodes.firstWhere((node) => id == node.id);
    } catch (_) {
      return null;
    }
  }

  LinkRef? findLinkRef(String id) {
    return findNode(id)?.toLinkRef();
  }

  NodeLinks findNodeLinks(String id) {
    final from = <LinkRef>[];
    final to = <LinkRef>[];
    for (final link in links) {
      if (link.source == id) {
        final ref = findLinkRef(link.target);
        if (ref != null) to.add(ref);
      }
      if (link.target == id) {
        final ref = findLinkRef(link.source);
        if (ref != null) from.add(ref);
      }
    }
    return NodeLinks(from, to);
  }
}

extension NodeExtension on Node {
  LinkRef toLinkRef() => LinkRef(id, title);
}

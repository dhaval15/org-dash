import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

import '../expr/expr.dart';
import '../models/models.dart';

class ApiHandlers {
  final Neuron neuron;
  final String Function(String path)? pathTransformer;
  static NeuronOptions options = NeuronOptions.defaultOptions;

  ApiHandlers({
    required this.neuron,
    this.pathTransformer,
  }) {
    neuron.refineWithOptions(options);
  }

  Response setOptions(Request req) {
    final params = req.url.queryParameters;
    options = NeuronOptions.fromJson(params);
    //TODO : Save options locally
    return Response.ok('Successful');
  }

  Response getContent(Request req, String id) {
    final originalPath = neuron.nodes.where((node) => node.id == id).first.file;
    final newPath = pathTransformer?.call(originalPath) ?? originalPath;
    final file = File(newPath);
    final text = file.readAsStringSync();
    return Response.ok(text);
  }

  Response nodeLinkRef(Request req) {
    final params = req.url.queryParameters;
    final id = params['id']!;
    final result = (neuron.findNodeLinkRef(id)).toJson();
    final content = JsonEncoder().convert(result);
    return Response.ok(content);
  }

  Response getNeuron(Request req) {
    final content = JsonEncoder().convert(neuron.toJson());
    return Response.ok(content);
  }

  Future<Response> expr(Request req) async {
    final params = req.url.queryParameters;
    final filterQuery = params['q'];
    final expression = Expression.parse(filterQuery!);
    final result = (await neuron.filter(expression)).toJson();
    final content = JsonEncoder().convert(result);
    return Response.ok(content);
  }
}

extension on Neuron {
  Future<Neuron> filter(Expression expression) async {
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

  void refineWithOptions(NeuronOptions options) {
    if (options.insertGhostNodes) {
      //TODO insert ghost nodes
    } else {
      final ids = nodes.map((node) => node.id).toList();
      links.removeWhere((link) => !ids.contains(link.target));
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
    final node = findNode(id);
    if (node != null) return LinkRef(id, node.title);
    return null;
  }

  NodeLinkRef findNodeLinkRef(String id) {
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
    return NodeLinkRef(from, to);
  }
}

class NodeLinkRef {
  final List<LinkRef> from;
  final List<LinkRef> to;

  NodeLinkRef(this.from, this.to);

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

class NeuronOptions {
  final bool insertGhostNodes;
  final List<String>? linkTypes;

  const NeuronOptions({
    required this.insertGhostNodes,
    this.linkTypes,
  });

  static const defaultOptions = NeuronOptions(
    insertGhostNodes: false,
  );

  factory NeuronOptions.fromJson(Map<String, dynamic> json) => NeuronOptions(
        insertGhostNodes: json['insertGhostNodes'] ?? false,
        linkTypes: json['linkTypes'],
      );
}

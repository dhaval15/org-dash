import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

import '../expr/expr.dart';
import '../models/models.dart';

class ApiHandlers {
  final Neuron neuron;
  final String Function(String path)? pathTransformer;

  ApiHandlers({
    required this.neuron,
    this.pathTransformer,
  });

  Response getContent(Request req, String id) {
    final originalPath = neuron.nodes.where((node) => node.id == id).first.file;
    final newPath = pathTransformer?.call(originalPath) ?? originalPath;
    final file = File(newPath);
    final text = file.readAsStringSync();
    return Response.ok(text);
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
}

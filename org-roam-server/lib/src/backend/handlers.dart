import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

import '../expr/expr.dart';
import '../models/models.dart';

class ApiHandlers {
  final Neuron neuron;
  final String Function(String path)? pathTransformer;

  const ApiHandlers({
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
    final content = JsonEncoder().convert({
      'type': 'graphdata',
      'data': neuron.toJson(),
    });
    return Response.ok(content);
  }

  Future<Response> expr(Request req) async {
    final params = req.url.queryParameters;
    final filterQuery = params['q'];
    final expression = Expression.parse(filterQuery!);
    final content = JsonEncoder().convert({
      'type': 'graphdata',
      'data': neuron.filter(expression).toJson(),
    });
    return Response.ok(content);
  }
}

extension on Neuron {
  Neuron filter(Expression expression) {
    final newNodes = nodes.where(expression.evaluate).toList();
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

import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import 'models.dart';
import 'parser.dart';

class FrontEndServer {
  final Graph graph;
  final int port;
  final Handler _staticHandler;
  final String Function(String path)? pathTransformer;

  FrontEndServer({
    required this.graph,
    required this.port,
    required String publicPath,
    this.pathTransformer,
  }) : _staticHandler = shelf_static.createStaticHandler(publicPath,
            defaultDocument: 'index.html');

  Future<void> init() async {
    final cascade = Cascade().add(_staticHandler).add(_router);

    final server = await shelf_io.serve(
      logRequests().addHandler(cascade.handler),
      InternetAddress.anyIPv4,
      port,
    );

    print('Serving at http://${server.address.host}:${server.port}');
  }

  shelf_router.Router get _router => shelf_router.Router()
    ..get('/node/<id>', _getNodeContent)
    ..get('/filter', _filterGraph)
    ..get('/data', _getGraph);

  Response _getNodeContent(Request req, String id) {
    final originalPath = graph.nodes.where((node) => node.id == id).first.file;
    final newPath = pathTransformer?.call(originalPath) ?? originalPath;
    final file = File(newPath);
    final text = file.readAsStringSync();
    return Response.ok(text);
  }

  Response _getGraph(Request req) {
    final content = JsonEncoder().convert({
      'type': 'graphdata',
      'data': graph.toJson(),
    });
    return Response.ok(content);
  }

  Future<Response> _filterGraph(Request req) async {
    final params = req.url.queryParameters;
    final filterQuery = params['q'];
    final expression = ExpressionParser.parse(filterQuery!);
    final content = JsonEncoder().convert({
      'type': 'graphdata',
      'data': graph.filter(expression).toJson(),
    });
    return Response.ok(content);
  }
}

extension on Graph {
  Graph filter(Expression expression) {
    final newNodes = nodes.where(expression.evaluate).toList();
    final newNodeIds = nodes.map((node) => node.id).toList();
    final newLinks = links
        .where((link) =>
            newNodeIds.contains(link.source) &&
            newNodeIds.contains(link.target))
        .toList();
    final newTags =
        nodes.fold<Set<String>>({}, (prev, node) => prev..addAll(node.tags));
    return Graph(
      nodes: newNodes,
      links: newLinks,
      tags: newTags.toList(),
    );
  }
}

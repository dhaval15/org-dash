import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:shelf_router/shelf_router.dart';

import '../expr/expr.dart';
import '../models/models.dart';
import 'router_context.dart';

class ApiRouter {
	final RouterContext context;

  const ApiRouter(this.context);

  Router create() => Router()
    ..get('/api/content/<id>', getContent)
    ..get('/api/expr', getExpr)
    ..get('/api/options', getOptions)
    ..post('/api/options', setOptions)
    ..get('/api/nodelinkref', getNodeLinks)
    ..get('/api/neuron', getNeuron);

  Response getContent(Request req, String id) {
    final originalPath = context.neuron.nodes.where((node) => node.id == id).first.file;
    final newPath = context.transformPath(originalPath);
    final file = File(newPath);
    final text = file.readAsStringSync();
    return Response.ok(text);
  }

  Response getOptions(Request req) {
    return Response.ok(context.encoder.convert(context.options.toJson()));
  }

  Response setOptions(Request req) {
    //TODO
		return Response.ok('Yet to be implemented');
  }

  Response getNodeLinks(Request req) {
    final params = req.url.queryParameters;
    final id = params['id']!;
    final result = (context.neuron.findNodeLinks(id)).toJson();
    final content = context.encoder.convert(result);
    return Response.ok(content);
  }

  Response getNeuron(Request req) {
    final content = context.encoder.convert(context.neuron.toJson());
    return Response.ok(content);
  }

  Future<Response> getExpr(Request req) async {
    final params = req.url.queryParameters;
    final filterQuery = params['q'];
    final expression = Expression.parse(filterQuery!);
    final result = (await context.neuron.expr(expression)).toJson();
    final content = context.encoder.convert(result);
    return Response.ok(content);
  }
}
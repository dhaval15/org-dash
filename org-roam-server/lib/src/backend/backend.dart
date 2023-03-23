import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import '../models/models.dart';
import 'handlers.dart';

class NeuronBackend {
  final int port;
  final Handler staticHandler;
  final ApiHandlers handlers;

  NeuronBackend({
    required Neuron neuron,
    required this.port,
    required String publicPath,
    String Function(String path)? pathTransformer,
  })  : staticHandler = shelf_static.createStaticHandler(publicPath,
            defaultDocument: 'index.html'),
        handlers = ApiHandlers(
          neuron: neuron,
          pathTransformer: pathTransformer,
        );

  Future<void> init() async {
    final cascade = Cascade().add(staticHandler).add(router);

    final server = await shelf_io.serve(
      logRequests().addHandler(cascade.handler),
      InternetAddress.anyIPv4,
      port,
    );

    print('Serving at http://${server.address.host}:${server.port}');
  }

  shelf_router.Router get router => shelf_router.Router()
    ..get('/api/content/<id>', handlers.getContent)
    ..get('/api/expr', handlers.expr)
    ..get('/api/neuron', handlers.getNeuron);
}

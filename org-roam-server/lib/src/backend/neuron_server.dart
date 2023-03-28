import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'logger.dart';
import 'api_router.dart';
import 'vue_router.dart';


class NeuronServer {
  final int port;
  final ApiRouter apiRouter;
  final VueRouter vueRouter;
	final Logger logger;

  const NeuronServer({
    required this.port,
    required this.apiRouter,
    required this.vueRouter,
		this.logger = const Logger(),
  });

  Future<void> init() async {
    final cascade = Cascade().add(vueRouter.create()).add(apiRouter.create());

    final server = await shelf_io.serve(
      logRequests(logger: logger).addHandler(cascade.handler),
      InternetAddress.anyIPv4,
      port,
    );

    print('Serving at http://${server.address.host}:${server.port}');
  }
}

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

class VueRouter {
  final String public;
  final String index;

  const VueRouter(this.public, [this.index = 'index.html']);

  Handler create() => createStaticHandler(public, defaultDocument: index);
}

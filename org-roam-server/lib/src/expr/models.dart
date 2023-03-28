import 'dart:async';
import 'dart:io';

import '../models/models.dart';
import 'parser.dart';

abstract class Expression<T> {
  const Expression();
  static final parser = ExpressionParserDefinition().build();

  static Expression parse(String input) =>
      parser.parse(input).value as Expression;

  String get method;

  List<T> get arguments;

  FutureOr<bool> evaluate(Node node);

  String toString() {
    final buffer = StringBuffer();
    buffer.write('($method ');
    buffer.write(
        arguments.map((e) => e is String ? '"$e"' : e.toString()).join(' '));
    buffer.write(')');
    return buffer.toString();
  }
}

class PropExpression extends Expression<String> {
  const PropExpression(this.property, this.values);

  @override
  String get method => "prop";

  final List<String> values;
  final String property;

  @override
  List<String> get arguments => [property, ... values];

  @override
  bool evaluate(Node node) {
    return values.contains(node.properties[property]);
  }

}

class TypeExpression extends Expression<String> {
  TypeExpression(this.types);

  @override
  String get method => "type";
  final List<String> types;

  @override
  List<String> get arguments => types;

  @override
  bool evaluate(Node node) {
    return types.contains(node.type);
  }
}

class GenreExpression extends Expression<String> {
  GenreExpression(this.genres);

  @override
  String get method => "genre";
  final List<String> genres;

  @override
  List<String> get arguments => genres;

  @override
  bool evaluate(Node node) {
    return genres.contains(node.genre);
  }
}

class SpaceExpression extends Expression<String> {
  SpaceExpression(this.spaces);

  @override
  String get method => "space";
  final List<String> spaces;

  @override
  List<String> get arguments => spaces;

  @override
  bool evaluate(Node node) {
    return spaces.contains(node.space);
  }
}

class AndExpression extends Expression<Expression> {
  @override
  final List<Expression> arguments;

  AndExpression(this.arguments);

  @override
  FutureOr<bool> evaluate(Node node) async {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (!await e.evaluate(node)) {
        return false;
      }
    }
    return true;
  }

  @override
  String get method => 'and';
}

class OrExpression extends Expression<Expression> {
  @override
  final List<Expression> arguments;

  OrExpression(this.arguments);

  @override
  FutureOr<bool> evaluate(Node node) async {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (await e.evaluate(node)) {
        return true;
      }
    }
    return false;
  }

  @override
  String get method => 'or';
}

class NotExpression extends Expression<Expression> {
  final Expression expression;
  @override
  List<Expression> get arguments => [expression];

  NotExpression(this.expression);

  @override
  Future<bool> evaluate(Node node) async {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (await e.evaluate(node)) {
        return true;
      }
    }
    return false;
  }

  @override
  String get method => 'or';
}

class RegexpExpression extends Expression<String> {
  static String Function(String path)? pathTransformer;
  RegexpExpression(this.query);

  @override
  String get method => "regex";
  final String query;

  @override
  List<String> get arguments => [query];

  @override
  FutureOr<bool> evaluate(Node node) async {
    final path = pathTransformer?.call(node.file) ?? node.file;
    final lines = await File(path).readAsLines();
    final regex = RegExp(query);
    for (final line in lines) {
      if (regex.hasMatch(line)) {
        return true;
      }
    }
    return false;
  }
}

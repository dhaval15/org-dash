import '../models/models.dart';
import 'parser.dart';

abstract class Expression<T> {
  static final parser = ExpressionParserDefinition().build();

  static Expression parse(String input) =>
      parser.parse(input).value as Expression;

  String get method;

  List<T> get arguments;

  bool evaluate(Node node);

  String toString() {
    final buffer = StringBuffer();
    buffer.write('($method ');
    buffer.write(
        arguments.map((e) => e is String ? '"$e"' : e.toString()).join(' '));
    buffer.write(')');
    return buffer.toString();
  }
}

class TypeExpression extends Expression<String> {
  TypeExpression(this.type);

  @override
  String get method => "type";
  final String type;

  @override
  List<String> get arguments => [type];

  @override
  bool evaluate(Node node) {
    return node.type == type;
  }
}

class GenreExpression extends Expression<String> {
  GenreExpression(this.genre);

  @override
  String get method => "genre";
  final String genre;

  @override
  List<String> get arguments => [genre];

  @override
  bool evaluate(Node node) {
    return node.genre == genre;
  }
}

class SpaceExpression extends Expression<String> {
  SpaceExpression(this.space);

  @override
  String get method => "space";
  final String space;

  @override
  List<String> get arguments => [space];

  @override
  bool evaluate(Node node) {
    return node.space == space;
  }
}

class TypeInExpression extends Expression<String> {
  TypeInExpression(this.types);

  @override
  String get method => "type-in";
  final List<String> types;

  @override
  List<String> get arguments => types;

  @override
  bool evaluate(Node node) {
    return types.contains(node.type);
  }
}

class GenreInExpression extends Expression<String> {
  GenreInExpression(this.genres);

  @override
  String get method => "genre-in";
  final List<String> genres;

  @override
  List<String> get arguments => genres;

  @override
  bool evaluate(Node node) {
    return genres.contains(node.genre);
  }
}

class SpaceInExpression extends Expression<String> {
  SpaceInExpression(this.spaces);

  @override
  String get method => "space-in";
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
  bool evaluate(Node node) {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (!e.evaluate(node)) {
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
  bool evaluate(Node node) {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (e.evaluate(node)) {
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
  bool evaluate(Node node) {
    final iterator = arguments.iterator;
    Expression? e;
    while (iterator.moveNext()) {
      e = iterator.current;
      if (e.evaluate(node)) {
        return true;
      }
    }
    return false;
  }

  @override
  String get method => 'or';
}

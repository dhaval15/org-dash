import 'package:petitparser/petitparser.dart';

import 'models.dart';

class ExpressionParserDefinition extends _ExpressionGrammarDefinition {
  @override
  Parser expression() => super.expression().map((value) => value[1]);

  @override
  Parser type() => super.type().map((value) => TypeExpression(value[1]));

  @override
  Parser typeIn() => super.typeIn().map((value) => TypeInExpression(value[1]));

  @override
  Parser genre() => super.genre().map((value) => GenreExpression(value[1]));

  @override
  Parser genreIn() =>
      super.genreIn().map((value) => GenreInExpression(value[1]));

  @override
  Parser space() => super.space().map((value) => SpaceExpression(value[1]));

  @override
  Parser spaceIn() =>
      super.spaceIn().map((value) => SpaceInExpression(value[1]));

  @override
  Parser and() => super.and().map((value) => AndExpression(value[1]));

  @override
  Parser or() => super.or().map((value) => OrExpression(value[1]));

  @override
  Parser not() => super.not().map((value) => NotExpression(value[1]));

  @override
  Parser expressionArguments() =>
      super.expressionArguments().map((value) => List<Expression>.from(value));

  @override
  Parser stringArguments() =>
      super.stringArguments().map((value) => List<String>.from(value));

  @override
  Parser stringToken() =>
      super.stringToken().map((s) => s.substring(1, s.length - 1));
}

class _ExpressionGrammarDefinition extends GrammarDefinition with _TokenMixin {
  @override
  Parser runtime() => ref0(expression);

  Parser expression() =>
      ref1(token, _TokenMixin.openParenthesis) &
      ref0(expressionContent) &
      ref1(token, _TokenMixin.closeParenthesis);

  Parser expressionContent() =>
      ref0(type) |
      ref0(genre) |
      ref0(space) |
      ref0(typeIn) |
      ref0(genreIn) |
      ref0(spaceIn) |
      ref0(and) |
      ref0(or) |
      ref0(not);

  Parser stringArguments() => ref0(stringToken).plus();

  Parser expressionArguments() => ref0(expression).plus();

  Parser type() => ref1(token, 'type') & ref0(stringToken);

  Parser genre() => ref1(token, 'genre') & ref0(stringToken);

  Parser space() => ref1(token, 'space') & ref0(stringToken);

  Parser typeIn() => ref1(token, 'type-in') & ref0(stringArguments);

  Parser genreIn() => ref1(token, 'genre-in') & ref0(stringArguments);

  Parser spaceIn() => ref1(token, 'space-in') & ref0(stringArguments);

  Parser and() => ref1(token, 'and') & ref0(expressionArguments);

  Parser or() => ref1(token, 'or') & ref0(expressionArguments);

  Parser not() => ref1(token, 'not') & ref0(expression);

  Parser stringToken() => ref2(token, ref0(stringPrimitive), 'string');

  Parser characterPrimitive() =>
      ref0(characterNormal) | ref0(characterEscape) | ref0(characterUnicode);

  Parser characterNormal() => pattern('^"\\');

  Parser characterEscape() =>
      char('\\') & pattern(_TokenMixin.jsonEscapeChars.keys.join());

  Parser characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);

  Parser funcName() => pattern('_A-Za-z') & pattern('_0-9A-Za-z').star();

  Parser numberPrimitive() =>
      char('-').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      pattern('eE')
          .seq(pattern('-+').optional())
          .seq(digit().plus())
          .optional();

  Parser stringPrimitive() =>
      char('"') & ref0(characterPrimitive).star() & char('"');
}

mixin _TokenMixin on GrammarDefinition {
  static const String openParenthesis = '(';
  static const String closeParenthesis = ')';
  static const Map<String, String> jsonEscapeChars = {
    '\\': '\\',
    '/': '/',
    '"': '"',
    'b': '\b',
    'f': '\f',
    'n': '\n',
    'r': '\r',
    't': '\t',
  };

  Parser runtime();

  @override
  Parser start() => ref0(runtime).end();

  Parser token(Object source, [String? name]) {
    Parser parser;
    String? expected;
    if (source is String) {
      if (source.length == 1) {
        parser = char(source);
      } else {
        parser = string(source);
      }
      expected = name ?? source;
    } else if (source is Parser) {
      parser = source;
      expected = name;
    } else {
      throw ArgumentError('Unknown token type: $source.');
    }
    if (expected == null) {
      throw ArgumentError('Missing token name: $source');
    }
    return parser.flatten(expected).trim();
  }
}

dynamic toNum(String s) {
  final doubleValue = double.parse(s);
  final intValue = doubleValue.toInt();
  if (intValue - doubleValue == 0) {
    return intValue;
  } else {
    return doubleValue;
  }
}


String elispMapToJsonText(String text) => text
    .replaceAll('" . "', '" : "')
    .replaceAll(') (', ',')
    .replaceAll('((', '{')
    .replaceAll('))', '}');

String elispListToJsonText(String text) =>
    text.replaceAll('(', '[').replaceAll(')', ']');

String trimQuotes(String text) => text.substring(1, text.length - 1);

import 'package:math_algorithms/math_algorithms.dart';
import 'expression.dart';

Expression parse(String latexCode) {
  var fractionsRegex =
      r'([([{]?\d*(\^{{1}\d+([\+\*\-/]{1}\d+)*}{1})?[xyz]?\^?\*?)*\\frac{';
  if (_isSingleTerm(latexCode)) {
    // TODO: check if latexCode is a function or another expression that can be a SimpleExpression.
    if (latexCode.startsWith(RegExp(fractionsRegex))) {
      return parseToFraction(latexCode);
    } else {
      return SimpleExpression.fromSingleTerm(latexCode);
    }
  } else {
    return parseToSimpleExpression(latexCode);
  }
}

SimpleExpression parseToSimpleExpression(String latexCode) {
  var startOfSubString = 0;
  var terms = <SimpleExpression>[];
  _signsOutsidePunctuation(latexCode).forEach((position) {
    terms.add(parse(latexCode.substring(startOfSubString, position)));
    startOfSubString = position;
  });
  terms.add(
      SimpleExpression.fromSingleTerm(latexCode.substring(startOfSubString)));
  return SimpleExpression.fromTerms(terms);
}

Fraction parseToFraction(String latexCode) {
  var startOfNumerator = latexCode.indexOf('{', latexCode.indexOf(r'\frac'));
  var endOfNumerator = _findClosingPunctuation(
      latexCode.substring(startOfNumerator), PunctuationType.braces);
  var startOfDenominator = latexCode.indexOf('{', endOfNumerator);
  var endOfDenominator = _findClosingPunctuation(
      latexCode.substring(startOfDenominator), PunctuationType.braces);
  return Fraction(
      numerator:
          parse(latexCode.substring(startOfNumerator + 1, endOfNumerator)),
      denominator:
          parse(latexCode.substring(startOfDenominator + 1, endOfDenominator)));
}

bool isValidExpression(String latexCode) {
  return '{'.allMatches(latexCode).length == '}'.allMatches(latexCode).length &&
      '('.allMatches(latexCode).length == ')'.allMatches(latexCode).length &&
      '['.allMatches(latexCode).length == ']'.allMatches(latexCode).length;
}

// This function must receive in parameter a string starting with an opening
// acollade and returns the closing acollade which corresponds.
int _findClosingPunctuation(
    String stringWithPunctuations, PunctuationType type) {
  var openPunctuation = _parsePunctuationType(type)['open'],
      closePunctuation = _parsePunctuationType(type)['close'];
  var openPunctuationsCount = 0, closePunctuationIndex = 0;
  var stringLength = stringWithPunctuations.length;
  for (var i = 0; i < stringLength; i++) {
    if (stringWithPunctuations[i] == openPunctuation) {
      openPunctuationsCount++;
    } else if (stringWithPunctuations[i] == closePunctuation) {
      if (openPunctuationsCount == 1) {
        closePunctuationIndex = i;
      } else {
        openPunctuationsCount--;
      }
    }
  }
  return closePunctuationIndex;
}

Map<String, String> _parsePunctuationType(PunctuationType type) {
  var punctuations = {'open': '', 'close': ''};
  switch (type) {
    case PunctuationType.braces:
      punctuations['open'] = '{';
      punctuations['close'] = '}';
      break;
    case PunctuationType.brackets:
      punctuations['open'] = '(';
      punctuations['close'] = ')';
      break;
    case PunctuationType.squaresBrackets:
      punctuations['open'] = '[';
      punctuations['close'] = ']';
      break;
  }
  return punctuations;
}

// Only for + and -
List<int> _signsOutsidePunctuation(String latexCode) {
  var expressionLength = latexCode.length;
  var signsIndexes = <int>[];
  for (var i = 1; i < expressionLength; i++) {
    // Initialize i to 1 to skip the sign of the expression.
    var currentChar = latexCode[i];
    if (currentChar == '+' || currentChar == '-') {
      signsIndexes.add(i);
    } else if (currentChar == '{') {
      i = _findClosingPunctuation(
          latexCode.substring(i), PunctuationType.braces);
    } else if (currentChar == '(') {
      i = _findClosingPunctuation(
          latexCode.substring(i), PunctuationType.brackets);
    } else if (currentChar == '[') {
      i = _findClosingPunctuation(
          latexCode.substring(i), PunctuationType.squaresBrackets);
    }
  }
  return signsIndexes;
}

bool _isSingleTerm(String latexCode) {
  return _signsOutsidePunctuation(latexCode).isEmpty;
}

enum PunctuationType { braces, brackets, squaresBrackets }

import 'package:math_algorithms/math_algorithms.dart';
import 'package:math_algorithms/src/parsers.dart';
import 'fraction.dart';
import 'package:meta/meta.dart';

/// A mathematical expression.
///
/// [Expression] represents a
/// [mathematical expression](https://en.wikipedia.org/wiki/Expression_(mathematics)).
/// All the operations that can be applied to a **mathematical expression** can be applied
/// to [Expression], example: [operator +()], [expand()], [factorize]...
abstract class Expression {
  String _initialLatexCode = '', _latexCode = '';
  num _numericValue;
  Map _variables = <String, num>{};
  Sign _sign;

  Expression();

  Expression.fromNumber(num number) {
    _numericValue = number.toDouble();
  }

  Expression.fromLatexCode(String latexCode) {
    _initialLatexCode = latexCode;
    _latexCode = latexCode;
    switch (_latexCode[0]) {
      case '-':
        _sign = Sign.minus;
        _latexCode = _latexCode.substring(1);
        break;
      case '+':
        _sign = Sign.plus;
        _latexCode = _latexCode.substring(1);
        break;
      default:
        _sign = Sign.plus;
    }
  }

  /* ***************************** *\
  |*|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|*|  
  |*|    OPÉRATORS OVERLOADING    |*| 
  |*|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,|*|
  \*********************************/

  Expression operator +(Expression secondTerm) {
    if (secondTerm is Fraction) {
      return secondTerm + this;
    } else if (isNumeric() && secondTerm.isNumeric()) {
      return SimpleExpression.fromNumber(
          _numericValue + secondTerm.numericValue);
    } else {
      return SimpleExpression('$latexCode+(${secondTerm.latexCode})');
    }
  }

  Expression operator -(Expression secondTerm) {
    if (secondTerm is Fraction) {
      return secondTerm - this;
    } else if (isNumeric() && secondTerm.isNumeric()) {
      return SimpleExpression.fromNumber(
          _numericValue - secondTerm.numericValue);
    } else {
      return SimpleExpression('$latexCode-(${secondTerm.latexCode})');
    }
  }

  Expression operator /(Expression secondTerm) {
    if (secondTerm is Fraction) {
      return secondTerm / this;
    } else if (isNumeric() && secondTerm.isNumeric()) {
      return SimpleExpression.fromNumber(
          _numericValue / secondTerm.numericValue);
    } else {
      return Fraction(numerator: this, denominator: secondTerm);
    }
  }

  Expression operator *(Expression secondTerm) {
    if (secondTerm is Fraction) {
      return secondTerm * this;
    } else if (isNumeric() && secondTerm.isNumeric()) {
      return SimpleExpression.fromNumber(
          _numericValue * secondTerm.numericValue);
    } else {
      return SimpleExpression('$latexCode*(${secondTerm.latexCode})');
    }
  }

  bool operator ==(secondTerm) {
    if (secondTerm is Expression) {
      if (isNumeric() && secondTerm.isNumeric()) {
        return (secondTerm.numericValue == numericValue);
      } else {
        // TODO: compare algebraic value.
      }
    } else if (secondTerm is num) {
      if (isNumeric()) {
        return numericValue == secondTerm;
      }
    }
  }

  /* ***************************** *\
  |*|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|*|
  |*|           METHODS           |*|
  |*|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,|*|
  \*********************************/

  String get latexCode => _getLatexCode(this);
  double get numericValue => _numericValue;
  Sign get sign => _sign;
  Map<String, num> get variables => _variables;
  Expression get toDecimalFraction => decomposeToDecimalFraction(_numericValue);
  Fraction get multiplicativeInverse =>
      Fraction(numerator: SimpleExpression.fromNumber(1), denominator: this);

  bool isNumeric() => (_variables.isEmpty);
  bool isAlgebraic() => (_variables.isNotEmpty);

  void simplifie();

  void expand();

  void factorize();

  static Expression parse(String expression) {}
}

class SimpleExpression extends Expression {
  List _terms = <Expression>[];

  SimpleExpression(String latexCode) {
    var expression = parseToSimpleExpression(latexCode);
    _terms = expression._terms;
    _variables = expression._variables;
    _initialLatexCode = expression.latexCode;
    _numericValue = expression._numericValue;
  }

  SimpleExpression.fromSingleTerm(String latexCode)
      : super.fromLatexCode(latexCode);

  SimpleExpression.fromNumber(num number) : super.fromNumber(number);

  SimpleExpression.fromTerms(List<Expression> terms) {
    _terms = terms;
    terms.forEach((term) => _initialLatexCode += term._initialLatexCode);
    _latexCode = _initialLatexCode;
  }

  /* ***************************** *\
  |*|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|*|
  |*|           METHODS           |*|
  |*|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,|*|
  \*********************************/

  List<Expression> get numericTerms => _getTerms(whithVariables: false);
  List<Expression> get algebraicTerms => _getTerms(whithVariables: true);
  List<Expression> get terms => _terms;

  List<Expression> _getTerms({@required bool whithVariables}) {
    var terms = <Expression>[];
    if (whithVariables) {
      _terms.forEach((term) {
        if (term._variables.isNotEmpty) terms.add(term);
      });
    } else {
      _terms.forEach((term) {
        if (term._variables.isEmpty) terms.add(term);
      });
    }
    return terms;
  }

  @override
  void expand() {
    // doit creer de nouveau term en developpant
    if (_terms.length > 1) {
      _terms.forEach((term) => term.expand());
    }
    // doit avoir aucun sign ou un sign positif aprés le develeppement
    _sign = Sign.plus;
  }

  @override
  void factorize() {}

  @override
  void simplifie() {}
}

String _getLatexCode(Expression expression) {
  var latexCode = '';
  if (expression is SimpleExpression && expression._terms.isNotEmpty) {
    for (var i = 0; i < expression.terms.length; i++) {
      if (expression.terms[i].sign == Sign.plus && i != 0) {
        // i != 0 for not have something like +5+3 but 5+3.
        latexCode += '+';
      } else if (expression.terms[i].sign == Sign.minus) {
        latexCode += '-';
      }
      latexCode += expression.terms[i]._latexCode;
    }
  } else {
    if (expression.sign == Sign.minus) latexCode += '-';
    latexCode += expression._latexCode;
  }
  return latexCode;
}

enum Sign { plus, minus }

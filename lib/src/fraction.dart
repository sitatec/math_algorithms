
import 'package:math_algorithms/src/parsers.dart';

import 'expression.dart';
import 'package:meta/meta.dart';
import 'dart:math';

import 'package:math_algorithms/math_algorithms.dart';

/// A fraction (mathematics)
///
/// https://en.wikipedia.org/wiki/Fraction_(mathematics)
class Fraction extends Expression {
  Expression _numerator;
  Expression _denominator;
  double _value;
  
  Fraction({@required Expression numerator, @required Expression denominator}) {
    _numerator = numerator;
    _denominator = denominator;
    if (numerator.isNumeric() && denominator.isNumeric()) {
      _value = numerator.numericValue / denominator.numericValue;
    } else {
      _value = 0;
    }
  }

  Fraction.fromDouble(double number) {
    var numberStr = number.toString();
    if (numberStr.contains('.')) {
      var digitsAfterPointCount = numberStr.length - numberStr.indexOf('.');
      var numberWithoutPoint =
          double.parse(numberStr.replaceFirst(RegExp(r'.'), ''));
      _numerator = SimpleExpression.fromNumber(numberWithoutPoint);
      _denominator = SimpleExpression.fromNumber(pow(10, digitsAfterPointCount));
    }
  }

  Fraction.fromLatexCode(String latexCode){
    var factors = parseToFraction(latexCode);
    _numerator = factors._numerator;
    _denominator = factors._denominator;
  }

  /* ***************************** *\
  |*|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|*|  
  |*|    OPÉRATORS OVERLOADING    |*| 
  |*|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,|*|
  \*********************************/

  @override
  Fraction operator +(other) {
    if (other is Fraction) {
      if (other.denominator == denominator) {
        return Fraction(
            numerator: _numerator + other.numerator, denominator: _denominator);
      } else {
        return Fraction(
            numerator: (_numerator * other.denominator) +
                (_denominator * other.numerator),
            denominator: denominator * other.denominator);
      }
    } else {
      return Fraction(numerator: _numerator + other, denominator: _denominator);
    } 
  }

  @override
  Fraction operator -(other) {
    if (other is Fraction) {
      if (other.denominator == denominator) {
        return Fraction(
            numerator: numerator - other.numerator, denominator: denominator);
      } else {
        return Fraction(
            numerator: (numerator * other.denominator) -
                (denominator * other.numerator),
            denominator: denominator * other.denominator);
      }
    } else {
      return Fraction(numerator: numerator - other, denominator: denominator);
    }
  }

  @override
  Fraction operator *(Expression other) {
    if (other is Fraction) {
      return Fraction(
          numerator: _numerator * other.numerator,
          denominator: _denominator * other.denominator);
    } else {
      return Fraction(numerator: _numerator * other, denominator: _denominator);
    } 
  }

  @override
  Fraction operator /(Expression other) {
    return this * other.multiplicativeInverse;
  }

  /* ***************************** *\
  |*|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|*|
  |*|           METHODS           |*|
  |*|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,|*|
  \*********************************/

  Expression get numerator => _numerator;
  Expression get denominator => _denominator;
  double get value => _value;

  @override
  Fraction get multiplicativeInverse =>
      Fraction(numerator: _denominator, denominator: _numerator);

  @override
  void simplifie() {}

  @override
  void expand() {

  }

  @override
  void factorize() {}
}


SimpleExpression decomposeToDecimalFraction(double number) {
  var numberStr = number.toString();
  var indexOfDecimalPoint = numberStr.indexOf('.');
  var numberLength = numberStr.length;
  var digitsAfterPoint = numberStr.substring(indexOfDecimalPoint, numberLength);
  var expression = '${number.truncate()}';
  for (var i = 0, j = digitsAfterPoint.length; i < j; i++) {
    expression += '${digitsAfterPoint[i]}/${pow(10, (i + 1))}';
  }
  return SimpleExpression(expression);
}
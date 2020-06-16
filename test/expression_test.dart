import 'package:math_algorithms/math_algorithms.dart';
import 'package:test/test.dart';
void main() {
  test('parseToSimpleExpression(String latexCode) may return a SimpleExpression',(){
    var expressionString = r'-4+5(4x)-9\frac{3}{6}';
    SimpleExpression exp = parse(expressionString);
    var t = 'Expression: ${exp.latexCode}\nTerms:  ';
    exp.terms.forEach((element) { t += element.latexCode + ' ';  });
    print(t);
    expect(exp.latexCode, equals(expressionString));
  } );
}

class MathException{
  ExceptionType _type;
  String _message;
  MathException(this._type, [this._message]);
  String get message => _message;
  ExceptionType get type => _type;
}

enum ExceptionType{
  divisionByZero,
  operationBetweenIncompatibleType,
}
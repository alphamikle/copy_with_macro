import 'package:copy_with_macro/src/logic/with_constructor_macro.dart';

@WithConstructor()
class Root {}

@WithConstructor()
class Ex1 extends Root {
  final String field0;
}

class Ex2 {}

@WithConstructor()
class Ex3 {
  final String field;
}

@WithConstructor()
class Ex4 extends Ex1 {
  final String field;
}

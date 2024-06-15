import 'package:copy_with_macro/src/logic/copy_with_macro.dart';
import 'package:copy_with_macro/src/logic/with_constructor_macro.dart';

// @CopyWith()
// @WithConstructor()
// class Root {}
//
// @CopyWith()
// @WithConstructor()
// class Ex1 extends Root {
//   final String field0;
// }
//
// @CopyWith()
// class Ex2 {}
//
// @CopyWith()
// @WithConstructor()
// class Ex3 {
//   final String field;
// }
//
// @CopyWith()
// @WithConstructor()
// class Ex4 extends Ex1 {
//   final String field;
// }
//
// @CopyWith()
// class Ex6 extends Ex5 {
//   // If "field" will be named other, for example -
//   // "anotherField" there will be an error in the augmented class
//   const Ex6(super.field, {required this.ex4Field});
//
//   final Ex4 ex4Field;
// }

// @WithConstructor()
@CopyWith()
class Ex5 {
  // const Ex5(this.field);

  final String field;
}

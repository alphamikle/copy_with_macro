import 'package:copy_with_macro/src/logic/copy_with_macro.dart';
import 'package:copy_with_macro/src/logic/with_constructor_macro.dart';
import 'package:data_class/data_class.dart';
import 'package:json/json.dart';

@CopyWith()
@WithConstructor()
class Root {}

@CopyWith()
@WithConstructor()
class Ex1 extends Root {
  final String field0;
  final int? field1;
}

// @CopyWith()
// class Ex2 {}
//
@JsonCodable()
class Ex3 {
  final String field;
}
//
// @CopyWith()
// @WithConstructor()
// class Ex4 extends Ex1 {
//   final String field;
// }

// @CopyWith()
// class Ex6 extends Ex5 {
//   // If "field" will be named other, for example -
//   // "anotherField" there will be an error in the augmented class
//   const Ex6(super.field, {required this.ex4Field});
//
//   final Ex4 ex4Field;
// }

// @CopyWith()
// class Ex5 {
//   const Ex5(this.field);
//
//   final String field;
// }

// @JsonCodable()
// class DataClEx {
//   const DataClEx({required this.name});
//
//   final String name;
// }

void main() {
  const v1 = Ex1(field0: 'Field 0', field1: 1);
  // print(v1.field0);
  print(v1.copyWith());

  // const v3 = DataClEx(name: 'Mike');
  // final v4 = DataClEx.fromJson(v3.toJson());
  //
  // print(v4);
}

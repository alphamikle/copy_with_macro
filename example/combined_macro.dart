import 'package:copy_with_macro/src/domain/combine/logic/macro/combine.dart';
import 'package:copy_with_macro/src/domain/copy_with/logic/macro/copy_with_macro.dart';
import 'package:copy_with_macro/src/domain/equal/logic/macro/equal_macro.dart';
import 'package:copy_with_macro/src/domain/printable/logic/macro/printable_macro.dart';
import 'package:copy_with_macro/src/domain/with_constructor/logic/macro/with_constructor_macro.dart';

macro

class CombinedMacro extends Combine {
  const CombinedMacro()
      : super(
    const [
      Printable(),
      Equal(),
      CopyWith(),
      WithConstructor(),
    ],
  );
}

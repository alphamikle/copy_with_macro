import 'package:copy_with_macro/copy_with_macro.dart';
import 'package:copy_with_macro/src/logic/combine.dart';

macro

class Copy extends Combine {
  const Copy()
      : super(
    const [
      CopyWith(),
      WithConstructor(),
    ],
  );
}

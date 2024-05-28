import 'package:macros/macros.dart';

import 'class_info.dart';

typedef DeclarationOperation = Future<void> Function({
  required ClassInfo classInfo,
  required MemberDeclarationBuilder builder,
});

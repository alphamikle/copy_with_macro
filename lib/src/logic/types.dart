import 'package:macros/macros.dart';

import 'class_info.dart';

typedef DeclarationOperation = Future<void> Function({
  required ClassInfo classInfo,
  required MemberDeclarationBuilder builder,
});

typedef DefinitionOperation = Future<void> Function({
  required ClassInfo classInfo,
  required TypeDefinitionBuilder builder,
  required FunctionDefinitionBuilder method,
});

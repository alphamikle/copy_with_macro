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

final Uri dartCodePackage = Uri.parse('dart:core');
final Uri quiverHashLibrary = Uri.parse('package:copy_with_macro/src/modules/quiver/lib/src/core/hash.dart');

const String copyWithLiteral = 'copyWith';
const String copyWithNullLiteral = 'copyWithNull';

const String equalLiteral = '==';
const String objectFieldsLiteral = r'$fields';
const String hashCodeLiteral = 'hashCode';

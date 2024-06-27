import 'package:macros/macros.dart';

import '../../domain/class_info/logic/model/class_info.dart';
// ignore: avoid_relative_lib_imports
import '../../modules/quiver/lib/src/core/hash.dart' as hash;

const hashObjects = hash.hashObjects;

typedef DeclarationOperation = Future<void> Function({
  required ClassInfo classInfo,
  required MemberDeclarationBuilder builder,
});

typedef DefinitionOperation = Future<void> Function({
  required ClassInfo classInfo,
  required TypeDefinitionBuilder builder,
  required FunctionDefinitionBuilder method,
});

final Uri dartCorePackage = Uri.parse('dart:core');
final Uri typesLibrary = Uri.parse('package:copy_with_macro/src/service/type/types.dart');
final Uri toJsonAbleInterfaceLibrary = Uri.parse('package:copy_with_macro/src/domain/serializable_to_json/logic/interface/serializable_to_json_interface.dart');

const String copyWithLiteral = 'copyWith';
const String copyWithNullLiteral = 'copyWithNull';

const String equalLiteral = '==';
const String objectFieldsLiteral = r'$fields';
const String hashCodeLiteral = 'hashCode';
const String toStringLiteral = 'toString';
const String fromJsonLiteral = 'fromJson';
const String toJsonLiteral = 'toJson';

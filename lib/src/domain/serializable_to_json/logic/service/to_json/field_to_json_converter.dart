import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../class_info/logic/model/class_info.dart';
import '../../model/formal_parameter_declaration_info.dart';
import '../field_json_converter.dart';

typedef ToJsonConverterFactory = FieldToJsonConverter Function({
  required ClassInfo classInfo,
  required FormalParameterDeclarationInfo fieldInfo,
  required TypeDefinitionBuilder builder,
  required CaseConverter caseConverter,
});

/// Code converter for each specific field of the class
abstract class FieldToJsonConverter implements FieldJsonConverter {
  FieldToJsonConverter({
    required this.classInfo,
    required this.fieldInfo,
    required this.builder,
    required this.caseConverter,
  });

  @override
  final ClassInfo classInfo;

  @override
  final FormalParameterDeclarationInfo fieldInfo;

  @override
  final TypeDefinitionBuilder builder;

  @override
  final CaseConverter caseConverter;

  @override
  FutureOr<List<Object>> preConstructorCode(Identifiers ids);

  @override
  FutureOr<List<Object>> argumentCode(Identifiers ids);

  @override
  bool canProduceCode();
}

import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../class_info/logic/model/class_info.dart';
import '../../model/formal_parameter_declaration_info.dart';
import '../field_json_converter.dart';
import 'field_from_json_converter.dart';

class CommonFromJsonConverter extends FieldFromJsonConverter {
  CommonFromJsonConverter({
    required super.classInfo,
    required super.fieldInfo,
    required super.builder,
    required super.caseConverter,
  });

  factory CommonFromJsonConverter.create({
    required ClassInfo classInfo,
    required FormalParameterDeclarationInfo fieldInfo,
    required TypeDefinitionBuilder builder,
    required CaseConverter caseConverter,
  }) {
    return CommonFromJsonConverter(
      classInfo: classInfo,
      fieldInfo: fieldInfo,
      builder: builder,
      caseConverter: caseConverter,
    );
  }

  @override
  FutureOr<List<Object>> argumentCode(Identifiers ids) => [
        '      ${fieldInfo.name}: ',
        "json[r'${caseConverter(fieldInfo.name)}'] as ",
        fieldInfo.origin.type.code,
        ', // common\n',
      ];

  @override
  FutureOr<List<Object>> preConstructorCode(Identifiers ids) => [];

  @override
  bool canProduceCode() => fieldInfo.realType == null || fieldInfo.realType is! EnumDeclaration;
}

import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../../service/extension/macro_extensions.dart';
import '../../../../class_info/logic/model/class_info.dart';
import '../../model/formal_parameter_declaration_info.dart';
import '../field_json_converter.dart';
import 'field_from_json_converter.dart';

class EnumFromJsonConverter extends FieldFromJsonConverter {
  EnumFromJsonConverter({
    required super.classInfo,
    required super.fieldInfo,
    required super.builder,
    required super.caseConverter,
  });

  factory EnumFromJsonConverter.create({
    required ClassInfo classInfo,
    required FormalParameterDeclarationInfo fieldInfo,
    required TypeDefinitionBuilder builder,
    required CaseConverter caseConverter,
  }) {
    return EnumFromJsonConverter(
      classInfo: classInfo,
      fieldInfo: fieldInfo,
      builder: builder,
      caseConverter: caseConverter,
    );
  }

  bool get byName => true;

  @override
  FutureOr<List<Object>> preConstructorCode(Identifiers ids) {
    final Identifier? fieldType = fieldInfo.realType?.identifier;

    if (fieldType == null) {
      builder.logInfo('Not found the right type for field "${fieldInfo.name}"');
      return [];
    }

    if (byName) {
      return [];
    }

    return [
      '    final stringTo${fieldType.name} = ',
      fieldType,
      '.values.asNameMap().map((key, value) => ',
      ids.mapEntry,
      '(',
      ids.caseConverter,
      '(key, ',
      ids.namingStrategy,
      '.',
      ids.strategy.name,
      '), value));\n',
    ];
  }

  @override
  FutureOr<List<Object>> argumentCode(Identifiers ids) {
    final Identifier? fieldType = fieldInfo.realType?.identifier;

    if (fieldType == null) {
      builder.logInfo('Not found the right type for field "${fieldInfo.name}"');
      return [];
    }

    if (byName) {
      return [
        '      ${fieldInfo.name}: ',
        fieldType,
        '.values.byName(',
        ids.caseConverter,
        "(json[r'${caseConverter(fieldInfo.name)}'].toString(), ",
        ids.namingStrategy,
        '.',
        ids.strategy.name,
        ')), // enum\n'
      ];
    }

    return [
      '      ${fieldInfo.name}: ',
      "stringTo${fieldType.name}['\${json[r'${caseConverter(fieldInfo.name)}']}'] as ",
      fieldInfo.origin.type.code,
      ',\n',
    ];
  }

  @override
  bool canProduceCode() => fieldInfo.realType is EnumDeclaration;
}

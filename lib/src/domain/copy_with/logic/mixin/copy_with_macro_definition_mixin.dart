import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/formal_parameter_declaration_extension.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../class_info/logic/model/class_type.dart';

mixin CopyWithMacroDefinitionMixin on ClassInfoMixin {
  /// ? copyWith definitions
  Future<void> buildEmptyDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '();',
    ]);
    method.augment(code);
  }

  Future<void> buildConstructorBasedDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    if (classInfo.hasArguments == false) {
      if (classInfo.allFields.isNotEmpty) {
        return buildFieldBasedDefinition(classInfo: classInfo, builder: builder, method: method);
      }
      return buildEmptyDefinition(classInfo: classInfo, builder: builder, method: method);
    }
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '(',
      for (int i = 0; i < classInfo.posArguments.length; i++)
        ...i.spread(
          classInfo.posArguments,
          (int index, FormalParameterDeclaration value) => [
            value.identifier.name,
            ' ?? ',
            'this.',
            value.identifier.name,
            if (i < classInfo.posArguments.length - 1) ', ',
          ],
        ),
      if (classInfo.posArguments.isNotEmpty && classInfo.namedArguments.isNotEmpty) ', ',
      for (int i = 0; i < classInfo.namedArguments.length; i++)
        ...i.spread(
          classInfo.namedArguments,
          (int index, FormalParameterDeclaration value) => [
            value.identifier.name,
            ': ',
            value.identifier.name,
            ' ?? ',
            'this.',
            value.identifier.name,
            if (i < classInfo.namedArguments.length - 1) ', ',
          ],
        ),
      ');'
    ]);
    method.augment(code);
  }

  Future<void> buildFieldBasedDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    final List<FieldDeclaration> allFields = classInfo.allFields;
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '(',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
          (int index, FieldDeclaration value) => [
            value.identifier.name,
            ': ',
            value.identifier.name,
            ' ?? ',
            'this.',
            value.identifier.name,
            if (i < allFields.length - 1) ', ',
          ],
        ),
      ');'
    ]);
    method.augment(code);
  }

  DefinitionOperation selectSuccessorDefinitionOperation(ClassInfo classInfo) {
    assert(classInfo.inheritance == ClassInheritance.successor);

    final ClassInfo superInfo = classInfo.superInfo!;

    final DefinitionOperation operation = switch (superInfo.structure) {
      ClassStructure.empty => buildEmptyDefinition,
      ClassStructure.hasConstructor => buildConstructorBasedDefinition,
      ClassStructure.hasFields => superConstructorDefinitionAbsenceError,
      ClassStructure.hasFieldsAndConstructor => buildConstructorBasedDefinition,
    };

    return operation;
  }

  Future<void> superConstructorDefinitionAbsenceError({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    builder.logInfo('Constructor "${classInfo.superInfo?.name}$cName" not exists');
  }

  /// ? copyWithNullDefinitions
  Future<void> buildEmptyNullDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '();',
    ]);
    method.augment(code);
  }

  Future<void> buildConstructorBasedNullDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    if (classInfo.hasArguments == false) {
      if (classInfo.allFields.isNotEmpty) {
        return buildFieldBasedDefinition(classInfo: classInfo, builder: builder, method: method);
      }
      return buildEmptyDefinition(classInfo: classInfo, builder: builder, method: method);
    }
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '(',
      for (int i = 0; i < classInfo.posArguments.length; i++)
        ...i.spread(
          classInfo.posArguments,
          (int index, FormalParameterDeclaration value) {
            final TypeAnnotationCode notOmittedType = value.notOmittedTypeCode(classInfo, builder);

            return [
              if (notOmittedType.isNonNullable) ...[
                'this.',
                value.identifier.name,
              ],
              if (notOmittedType.isNullable) ...[
                value.identifier.name,
                ' == true',
                ' ? ',
                'null',
                ' : ',
                'this.',
                value.identifier.name,
              ],
              if (i < classInfo.posArguments.length - 1) ', ',
            ];
          },
        ),
      if (classInfo.posArguments.isNotEmpty && classInfo.namedArguments.isNotEmpty) ', ',
      for (int i = 0; i < classInfo.namedArguments.length; i++)
        ...i.spread(
          classInfo.namedArguments,
          (int index, FormalParameterDeclaration value) {
            final TypeAnnotationCode notOmittedType = value.notOmittedTypeCode(classInfo, builder);

            return [
              value.identifier.name,
              ': ',
              if (notOmittedType.isNonNullable) ...[
                'this.',
                value.identifier.name,
              ],
              if (notOmittedType.isNullable) ...[
                value.identifier.name,
                ' == true',
                ' ? ',
                'null',
                ' : ',
                'this.',
                value.identifier.name,
              ],
              if (i < classInfo.namedArguments.length - 1) ', ',
            ];
          },
        ),
      ');'
    ]);
    method.augment(code);
  }

  Future<void> buildFieldBasedNullDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    final List<FieldDeclaration> allFields = classInfo.allFields;
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '=> ',
      classInfo.name,
      cName,
      '(',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
          (int index, FieldDeclaration value) => [
            value.identifier.name,
            ': ',
            if (value.type.isNonNullable) ...[
              'this.',
              value.identifier.name,
            ],
            if (value.type.isNullable) ...[
              value.identifier.name,
              ' == true',
              ' ? ',
              'null',
              ' : ',
              'this.',
              value.identifier.name,
            ],
            if (i < allFields.length - 1) ', ',
          ],
        ),
      ');'
    ]);
    method.augment(code);
  }

  DefinitionOperation selectSuccessorNullDefinitionOperation(ClassInfo classInfo) {
    assert(classInfo.inheritance == ClassInheritance.successor);

    final ClassInfo superInfo = classInfo.superInfo!;

    final DefinitionOperation operation = switch (superInfo.structure) {
      ClassStructure.empty => buildEmptyDefinition,
      ClassStructure.hasConstructor => buildConstructorBasedDefinition,
      ClassStructure.hasFields => superConstructorDefinitionAbsenceError,
      ClassStructure.hasFieldsAndConstructor => buildConstructorBasedDefinition,
    };

    return operation;
  }
}

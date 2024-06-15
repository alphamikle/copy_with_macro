import 'package:macros/macros.dart';

import '../logic_old/common_extensions.dart';
import '../logic_old/macro_extensions.dart';
import 'class_info.dart';
import 'class_info_mixin.dart';
import 'class_type.dart';
import 'types.dart';

mixin CopyWithMacroDefinitionMacroMixin on ClassInfoMixin {
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
    builder.logInfo('All fields: $allFields');
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
}

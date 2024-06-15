import 'package:macros/macros.dart';

import '../logic_old/common_extensions.dart';
import '../logic_old/macro_extensions.dart';
import 'class_info.dart';
import 'class_info_mixin.dart';
import 'class_type.dart';
import 'field_declaration_extension.dart';
import 'formal_parameter_declaration_extension.dart';
import 'types.dart';

mixin CopyWithMacroDeclarationsMixin on ClassInfoMixin {
  Future<void> buildEmptyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} copyWith();',
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildConstructorBasedDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    if (classInfo.hasSuper == false && classInfo.hasArguments == false) {
      await buildEmptyDeclaration(classInfo: classInfo, builder: builder);
      return;
    }
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} copyWith({',
      for (int i = 0; i < classInfo.posArguments.length; i++)
        ...i.spread(
          classInfo.posArguments,
          (int index, FormalParameterDeclaration value) => [
            value.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < classInfo.posArguments.length - 1) ', ',
          ],
        ),
      if (classInfo.posArguments.isNotEmpty && classInfo.namedArguments.isNotEmpty) ', ',
      for (int i = 0; i < classInfo.namedArguments.length; i++)
        ...i.spread(
          classInfo.namedArguments,
          (int index, FormalParameterDeclaration value) => [
            value.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < classInfo.namedArguments.length - 1) ', ',
          ],
        ),
      '});',
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildFieldBasedDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} copyWith({',
      for (int i = 0; i < classInfo.fields.length; i++)
        ...i.spread(
          classInfo.fields,
          (int index, FieldDeclaration value) => [
            value.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < classInfo.fields.length - 1) ', ',
          ],
        ),
      if (classInfo.fields.isNotEmpty && classInfo.superFields.isNotEmpty) ', ',
      for (int i = 0; i < classInfo.superFields.length; i++)
        ...i.spread(
          classInfo.superFields,
          (int index, FieldDeclaration value) => [
            value.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < classInfo.superFields.length - 1) ', ',
          ],
        ),
      '});',
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildDeclarationForAllAncestors({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    // TODO(alphamikle): Continue
  }

  Future<void> superConstructorAbsenceError({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    builder.logInfo('Constructor "${classInfo.superInfo?.name}$cName" not exists');
  }

  DeclarationOperation selectSuccessorDeclarationOperation(ClassInfo classInfo) {
    assert(classInfo.inheritance == ClassInheritance.successor);

    final ClassInfo superInfo = classInfo.superInfo!;
    final DeclarationOperation operation = switch (superInfo.structure) {
      ClassStructure.empty => buildEmptyDeclaration,
      ClassStructure.hasConstructor => buildDeclarationForAllAncestors,
      ClassStructure.hasFields => superConstructorAbsenceError,
      ClassStructure.hasFieldsAndConstructor => buildDeclarationForAllAncestors,
    };

    return operation;
  }
}

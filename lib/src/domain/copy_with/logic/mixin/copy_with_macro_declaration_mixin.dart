import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/field_declaration_extension.dart';
import '../../../../service/extension/formal_parameter_declaration_extension.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../class_info/logic/model/class_type.dart';
import '../../../class_info/logic/model/super_field_declaration.dart';

mixin CopyWithMacroDeclarationMixin on ClassInfoMixin {
  Future<void> buildEmptyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} $copyWithLiteral();',
      '  external ${classInfo.name} $copyWithNullLiteral();',
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
    final List<FormalParameterDeclaration> arguments = classInfo.arguments;
    final List<FormalParameterDeclaration> nullableArguments = arguments.nullableOnly(classInfo, builder);
    final Identifier boolId = await builder.resolveId($bool);

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} $copyWithLiteral({',
      for (int i = 0; i < arguments.length; i++)
        ...i.spread(
          arguments,
          (int index, FormalParameterDeclaration value) => [
            value.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < arguments.length - 1) ', ',
          ],
        ),
      '});\n',
      '  external ${classInfo.name} $copyWithNullLiteral(',
      if (nullableArguments.isNotEmpty) ...[
        '{',
        for (int i = 0; i < nullableArguments.length; i++)
          ...i.spread(
            nullableArguments,
            (int index, FormalParameterDeclaration value) => [
              boolId,
              '?',
              ' ',
              value.identifier,
              if (i < nullableArguments.length - 1) ', ',
            ],
          ),
        '});'
      ],
      if (nullableArguments.isEmpty) ');',
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildFieldBasedDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final List<SuperFieldDeclaration> allFields = [...classInfo.fields, ...classInfo.superFields];
    final List<SuperFieldDeclaration> nullableFields = allFields.nullableOnly(classInfo, builder);
    final Identifier boolId = await builder.resolveId($bool);

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${classInfo.name} $copyWithLiteral({',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
          (int index, SuperFieldDeclaration value) => [
            value.original.notOmittedTypeCode(classInfo, builder).asNullable,
            ' ',
            value.identifier.name,
            if (i < allFields.length - 1) ', ',
          ],
        ),
      '});\n',
      '  external ${classInfo.name} $copyWithNullLiteral(',
      if (nullableFields.isNotEmpty) ...[
        '{',
        for (int i = 0; i < nullableFields.length; i++)
          ...i.spread(
            nullableFields,
            (int index, SuperFieldDeclaration value) => [
              boolId,
              '?',
              ' ',
              value.identifier.name,
              if (i < nullableFields.length - 1) ', ',
            ],
          ),
        '});'
      ],
      if (nullableFields.isEmpty) ');',
    ]);
    builder.declareInType(declaration);
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
      ClassStructure.hasConstructor => buildConstructorBasedDeclaration,
      ClassStructure.hasFields => superConstructorAbsenceError,
      ClassStructure.hasFieldsAndConstructor => buildConstructorBasedDeclaration,
    };

    return operation;
  }
}

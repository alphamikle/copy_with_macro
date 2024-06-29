import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/log/messages.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../class_info/logic/model/class_type.dart';
import '../../../class_info/logic/model/super_field_declaration.dart';

mixin WithConstructorDeclarationMixin on ClassInfoMixin {
  bool get allRequired;

  bool get explicitTypes;

  bool get useNoMethodFoundFix;

  FutureOr<void> buildDeclaration(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    //
    // final DeclarationOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
    //   /// ? Simple class
    //   (ClassInheritance.firstborn, ClassStructure.empty) => buildEmptyDeclaration,
    //   (ClassInheritance.firstborn, ClassStructure.hasConstructor) => constructorExistenceError,
    //   (ClassInheritance.firstborn, ClassStructure.hasFields) => buildFieldsOnlyDeclaration,
    //   (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => constructorExistenceError,
    //
    //   /// ? Class, which extends from another class
    //   (ClassInheritance.successor, ClassStructure.empty) => selectSuccessorDeclarationOperation(classInfo),
    //   (ClassInheritance.successor, ClassStructure.hasConstructor) => constructorExistenceError,
    //   (ClassInheritance.successor, ClassStructure.hasFields) => selectSuccessorDeclarationOperation(classInfo),
    //   (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => constructorExistenceError,
    // };
    //
    // await operation(classInfo: classInfo, builder: builder);
  }

  Future<List<Object>> noMethodFoundFix(TypePhaseIntrospector builder) async {
    if (useNoMethodFoundFix == false) {
      return [];
    }

    final Identifier stringId = await builder.resolveId($string);

    return [
      '\n',
      '  external ',
      stringId,
      ' get doNotCallMe;',
    ];
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

  Future<void> buildEmptyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName();',
      ...await noMethodFoundFix(builder),
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildFieldsOnlyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    if (classInfo.fields.isEmpty) {
      await buildEmptyDeclaration(classInfo: classInfo, builder: builder);
      return;
    }

    final List<SuperFieldDeclaration> fields = classInfo.fields;

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName({',
      for (int i = 0; i < fields.length; i++)
        ...i.spread(
          fields,
          (int index, SuperFieldDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            if (explicitTypes) value.type.code,
            if (explicitTypes) ' ',
            'this.',
            value.identifier.name,
            if (i < classInfo.fields.length - 1) ', '
          ],
        ),
      '});',
      ...await noMethodFoundFix(builder),
    ]);
    builder.declareInType(declaration);
  }

  Future<void> buildDeclarationForAllAncestors({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    assert(classInfo.superInfo?.constructor != null);

    final List<FormalParameterDeclaration> superPositionalParameters = classInfo.superPosArguments;
    final List<FormalParameterDeclaration> superNamedParameters = classInfo.superNamedArguments;
    final bool superHasParams = superPositionalParameters.isNotEmpty || superNamedParameters.isNotEmpty;

    if (superHasParams == false) {
      await buildFieldsOnlyDeclaration(classInfo: classInfo, builder: builder);
      return;
    }

    final List<SuperFieldDeclaration> fields = classInfo.fields;

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName({',

      /// ? Arguments of class itself
      for (int i = 0; i < fields.length; i++)
        ...i.spread(
          fields,
          (int index, SuperFieldDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            if (explicitTypes) value.type.code,
            if (explicitTypes) ' ',
            'this.',
            value.identifier.name,
            ', ',
          ],
        ),

      /// ? Constructor arguments, to pass to super constructor
      for (int i = 0; i < superPositionalParameters.length; i++)
        ...i.spread(
          superPositionalParameters,
          (int index, FormalParameterDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            if (explicitTypes) value.type.code,
            if (explicitTypes) ' ',
            value.identifier.name,
            if (superNamedParameters.isEmpty && i < superPositionalParameters.length - 1 || superNamedParameters.isNotEmpty) ', ',
          ],
        ),
      for (int i = 0; i < superNamedParameters.length; i++)
        ...i.spread(
          superNamedParameters,
          (int index, FormalParameterDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            if (explicitTypes) value.type.code,
            if (explicitTypes) ' ',
            value.identifier.name,
            if (i < superNamedParameters.length - 1) ', ',
          ],
        ),
      '}) : super$cName(',

      /// ? Super constructor arguments
      for (int i = 0; i < superPositionalParameters.length; i++)
        ...i.spread(
          superPositionalParameters,
          (int index, FormalParameterDeclaration value) => [
            value.identifier.name,
            if (superNamedParameters.isEmpty && i < superPositionalParameters.length - 1 || superNamedParameters.isNotEmpty) ', ',
          ],
        ),
      for (int i = 0; i < superNamedParameters.length; i++)
        ...i.spread(
          superNamedParameters,
          (int index, FormalParameterDeclaration value) => [
            value.identifier.name,
            ': ',
            value.identifier.name,
            if (i < superNamedParameters.length - 1) ', ',
          ],
        ),
      ');',
      ...await noMethodFoundFix(builder),
    ]);
    builder.declareInType(declaration);
  }

  Future<void> constructorExistenceError({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    builder.logInfo('Class "${classInfo.name}" already has ${constructorName(name)}');
  }

  Future<void> superConstructorAbsenceError({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    builder.logInfo('Class "${classInfo.name}" should have ${constructorName(name)}');
  }
}

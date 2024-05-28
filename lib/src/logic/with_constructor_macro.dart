import 'dart:async';

import 'package:macros/macros.dart';

import '../logic_old/common_extensions.dart';
import '../logic_old/macro_extensions.dart';
import 'class_info.dart';
import 'class_info_mixin.dart';
import 'class_type.dart';
import 'messages.dart';
import 'types.dart';

class WithConstructor with ClassInfoMixin implements ClassDeclarationsMacro {
  const WithConstructor({
    this.name = '',
    this.allRequired = true,
  });

  @override
  final String name;

  final bool allRequired;

  String get cName {
    if (name == '') {
      return '';
    }
    return '.$name';
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);

    final DeclarationOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
      /// ? Simple class
      (ClassInheritance.firstborn, ClassStructure.empty) => _buildEmptyDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => _constructorExistenceError,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => _buildFieldsOnlyDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => _constructorExistenceError,

      /// ? Class, which extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => _selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => _constructorExistenceError,
      (ClassInheritance.successor, ClassStructure.hasFields) => _selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => _constructorExistenceError,
    };

    await operation(classInfo: classInfo, builder: builder);
  }

  DeclarationOperation _selectSuccessorDeclarationOperation(ClassInfo classInfo) {
    assert(classInfo.inheritance == ClassInheritance.successor);

    final ClassInfo superInfo = classInfo.superInfo!;
    final DeclarationOperation operation = switch (superInfo.structure) {
      ClassStructure.empty => _buildEmptyDeclaration,
      ClassStructure.hasConstructor => _buildDeclarationForAllAncestors,
      ClassStructure.hasFields => _superConstructorAbsenceError,
      ClassStructure.hasFieldsAndConstructor => _buildDeclarationForAllAncestors,
    };

    return operation;
  }

  Future<void> _buildEmptyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName();',
    ]);
    builder.declareInType(declaration);
  }

  Future<void> _buildFieldsOnlyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    if (classInfo.fields.isEmpty) {
      await _buildEmptyDeclaration(classInfo: classInfo, builder: builder);
      return;
    }

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName({',
      for (int i = 0; i < classInfo.fields.length; i++)
        ...i.spread(
          classInfo.fields,
          (int index, FieldDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            value.type.code,
            ' ',
            'this.',
            value.identifier.name,
            if (i < classInfo.fields.length - 1) ', '
          ],
        ),
      '});'
    ]);
    builder.declareInType(declaration);
  }

  Future<void> _buildDeclarationForAllAncestors({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    assert(classInfo.superInfo?.constructor != null);

    final List<FormalParameterDeclaration> superPositionalParameters = classInfo.superInfo!.constructor!.positionalParameters.toList();
    final List<FormalParameterDeclaration> superNamedParameters = classInfo.superInfo!.constructor!.namedParameters.toList();
    final bool superHasParams = superPositionalParameters.isNotEmpty || superNamedParameters.isNotEmpty;

    if (superHasParams == false) {
      await _buildFieldsOnlyDeclaration(classInfo: classInfo, builder: builder);
      return;
    }

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${classInfo.name}$cName({',

      /// ? Arguments of class itself
      for (int i = 0; i < classInfo.fields.length; i++)
        ...i.spread(
          classInfo.fields,
          (int index, FieldDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            value.type.code,
            ' ',
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
            value.type.code,
            ' ',
            value.identifier.name,
            if (superNamedParameters.isEmpty && i < superPositionalParameters.length - 1 || superNamedParameters.isNotEmpty) ', ',
          ],
        ),
      for (int i = 0; i < superNamedParameters.length; i++)
        ...i.spread(
          superNamedParameters,
          (int index, FormalParameterDeclaration value) => [
            if (allRequired || value.type.isNonNullable) 'required ',
            value.type.code,
            ' ',
            value.identifier.name,
            if (i < superNamedParameters.length - 1) ', ',
          ],
        ),
      '}) : super(',

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
      ');'
    ]);
    builder.declareInType(declaration);
  }

  Future<void> _constructorExistenceError({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    builder.logInfo('Class "${classInfo.name}" already has ${constructorName(name)}');
  }

  Future<void> _superConstructorAbsenceError({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    builder.logInfo('Class "${classInfo.name}" should have ${constructorName(name)}');
  }
}

import 'dart:async';

import 'package:macros/macros.dart';

import '../logic_old/common_extensions.dart';
import '../logic_old/macro_extensions.dart';
import 'class_info.dart';
import 'class_info_mixin.dart';
import 'class_type.dart';
import 'copy_with_macro_declarations_mixin.dart';
import 'types.dart';

const String _cp = 'copyWith';

macro class CopyWith with ClassInfoMixin, CopyWithMacroDeclarationsMixin implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const CopyWith({
    this.name = '',
  });

  @override
  final String name;

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);

    final DeclarationOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
      /// ? Simple class
      (ClassInheritance.firstborn, ClassStructure.empty) => buildEmptyDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => buildConstructorBasedDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => buildFieldBasedDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedDeclaration,

      /// ? Class, that extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => buildConstructorBasedDeclaration,
      (ClassInheritance.successor, ClassStructure.hasFields) => selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedDeclaration,
    };

    await operation(classInfo: classInfo, builder: builder);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);

    builder.logInfo('Class info: ${clazz.identifier.name}; inh = ${classInfo.inheritance}; strut = ${classInfo.structure}');

    final List<MethodDeclaration> methods = await builder.methodsOf(clazz);
    final MethodDeclaration? copyWithDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == _cp);

    if (copyWithDeclaration == null) {
      return;
    }

    final FunctionDefinitionBuilder copyWithMethod = await builder.buildMethod(copyWithDeclaration.identifier);

    final DefinitionOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
      /// ? Simple class
      (ClassInheritance.firstborn, ClassStructure.empty) => _buildEmptyDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => _buildConstructorBasedDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => _buildFieldBasedDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => _buildConstructorBasedDefinition,

      /// ? Class, that extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => _selectSuccessorDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => _buildConstructorBasedDefinition,
      (ClassInheritance.successor, ClassStructure.hasFields) => _selectSuccessorDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => _buildConstructorBasedDefinition,
    };

    await operation(classInfo: classInfo, builder: builder, method: copyWithMethod);
  }

  Future<void> _buildEmptyDefinition({
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

  Future<void> _buildConstructorBasedDefinition({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    if (classInfo.hasArguments == false) {
      if (classInfo.allFields.isNotEmpty) {
        return _buildFieldBasedDefinition(classInfo: classInfo, builder: builder, method: method);
      }
      return _buildEmptyDefinition(classInfo: classInfo, builder: builder, method: method);
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

  Future<void> _buildFieldBasedDefinition({
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

  DefinitionOperation _selectSuccessorDefinitionOperation(ClassInfo classInfo) {
    assert(classInfo.inheritance == ClassInheritance.successor);

    final ClassInfo superInfo = classInfo.superInfo!;

    final DefinitionOperation operation = switch (superInfo.structure) {
      ClassStructure.empty => _buildEmptyDefinition,
      ClassStructure.hasConstructor => _buildConstructorBasedDefinition,
      ClassStructure.hasFields => _superConstructorDefinitionAbsenceError,
      ClassStructure.hasFieldsAndConstructor => _buildConstructorBasedDefinition,
    };

    return operation;
  }

  Future<void> _superConstructorDefinitionAbsenceError({
    required ClassInfo classInfo,
    required TypeDefinitionBuilder builder,
    required FunctionDefinitionBuilder method,
  }) async {
    builder.logInfo('Constructor "${classInfo.superInfo?.name}$cName" not exists');
  }
}

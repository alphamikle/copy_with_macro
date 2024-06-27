import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../class_info/logic/model/class_type.dart';
import '../mixin/copy_with_macro_declaration_mixin.dart';
import '../mixin/copy_with_macro_definition_mixin.dart';

macro

class CopyWith
    with ClassInfoMixin, CopyWithMacroDeclarationMixin, CopyWithMacroDefinitionMixin
    implements
        ClassDeclarationsMacro,
        ClassDefinitionMacro {
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
    await _defineCopyWithMethod(clazz, builder);
    await _defineCopyWithNullMethod(clazz, builder);
  }

  Future<void> _defineCopyWithMethod(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);

    final List<MethodDeclaration> methods = await builder.methodsOf(clazz);
    final MethodDeclaration? copyWithDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == copyWithLiteral);

    if (copyWithDeclaration == null) {
      return;
    }

    final FunctionDefinitionBuilder copyWithMethod = await builder.buildMethod(copyWithDeclaration.identifier);

    final DefinitionOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
    /// ? Simple class
      (ClassInheritance.firstborn, ClassStructure.empty) => buildEmptyDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => buildConstructorBasedDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => buildFieldBasedDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedDefinition,

    /// ? Class, that extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => selectSuccessorDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => buildConstructorBasedDefinition,
      (ClassInheritance.successor, ClassStructure.hasFields) => selectSuccessorDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedDefinition,
    };

    await operation(classInfo: classInfo, builder: builder, method: copyWithMethod);
  }

  Future<void> _defineCopyWithNullMethod(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);

    final List<MethodDeclaration> methods = await builder.methodsOf(clazz);
    final MethodDeclaration? copyWithNullDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == copyWithNullLiteral);

    if (copyWithNullDeclaration == null) {
      return;
    }

    final FunctionDefinitionBuilder copyWithNullMethod = await builder.buildMethod(copyWithNullDeclaration.identifier);

    final DefinitionOperation operation = switch ((classInfo.inheritance, classInfo.structure)) {
    /// ? Simple class
      (ClassInheritance.firstborn, ClassStructure.empty) => buildEmptyNullDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => buildConstructorBasedNullDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => buildFieldBasedNullDefinition,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedNullDefinition,

    /// ? Class, that extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => selectSuccessorNullDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => buildConstructorBasedNullDefinition,
      (ClassInheritance.successor, ClassStructure.hasFields) => selectSuccessorNullDefinitionOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => buildConstructorBasedNullDefinition,
    };

    await operation(classInfo: classInfo, builder: builder, method: copyWithNullMethod);
  }
}

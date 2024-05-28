import 'dart:async';

import 'package:macros/macros.dart';

import 'class_info.dart';
import 'class_info_mixin.dart';
import 'class_type.dart';
import 'types.dart';

class CopyWith with ClassInfoMixin implements ClassDeclarationsMacro, ClassDefinitionMacro {
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
      (ClassInheritance.firstborn, ClassStructure.empty) => _buildEmptyDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasConstructor) => _buildConstructorBasedDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasFields) => _buildFieldBasedDeclaration,
      (ClassInheritance.firstborn, ClassStructure.hasFieldsAndConstructor) => _buildConstructorBasedDeclaration,

      /// ? Class, that extends from another class
      (ClassInheritance.successor, ClassStructure.empty) => _selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasConstructor) => _buildConstructorBasedDeclaration,
      (ClassInheritance.successor, ClassStructure.hasFields) => _selectSuccessorDeclarationOperation(classInfo),
      (ClassInheritance.successor, ClassStructure.hasFieldsAndConstructor) => _buildConstructorBasedDeclaration,
    };

    await operation(classInfo: classInfo, builder: builder);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    // TODO(alphamikle):
  }

  Future<void> _buildEmptyDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    // TODO(alphamikle):
  }

  Future<void> _buildConstructorBasedDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    // TODO(alphamikle):
  }

  Future<void> _buildFieldBasedDeclaration({
    required ClassInfo classInfo,
    required MemberDeclarationBuilder builder,
  }) async {
    // TODO(alphamikle):
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
}

import 'dart:async';

import 'package:macros/macros.dart';

import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../mixin/equal_macro_declaration_mixin.dart';
import '../mixin/equal_macro_definition_mixin.dart';


macro

class Equal with ClassInfoMixin, EqualMacroDeclarationMixin, EqualMacroDefinitionMixin implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const Equal();

  @override
  String get name => '';

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await declareOperator(clazz, builder);
    await declareFields(clazz, builder);
    await declareHashcode(clazz, builder);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    await defineOperator(clazz, builder);
    await defineFields(clazz, builder);
    await defineHashcode(clazz, builder);
  }
}

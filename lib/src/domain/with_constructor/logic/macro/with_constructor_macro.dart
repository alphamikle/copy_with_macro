import 'dart:async';

import 'package:macros/macros.dart';

import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../mixin/with_constructor_macro_declaration_mixin.dart';

macro

class WithConstructor with ClassInfoMixin, WithConstructorDeclarationMixin implements ClassDeclarationsMacro {
  const WithConstructor({
    this.name = '',
    this.allRequired = true,
    this.explicitTypes = false,
  });

  @override
  final String name;

  @override
  final bool allRequired;

  @override
  final bool explicitTypes;

  @override
  bool get useNoMethodFoundFix => true;

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await buildDeclaration(clazz, builder);
  }
}

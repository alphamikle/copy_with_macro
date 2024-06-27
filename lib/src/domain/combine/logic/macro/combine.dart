import 'dart:async';

import 'package:macros/macros.dart';

macro

class Combine implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const Combine(this.macros);

  final List<Macro> macros;

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await Future.wait(macros.whereType<ClassDeclarationsMacro>().map((ClassDeclarationsMacro macro) async {
      await macro.buildDeclarationsForClass(clazz, builder);
    }));
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    await Future.wait(macros.whereType<ClassDefinitionMacro>().map((ClassDefinitionMacro macro) async {
      await macro.buildDefinitionForClass(clazz, builder);
    }));
  }
}

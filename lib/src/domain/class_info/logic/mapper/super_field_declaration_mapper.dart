import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/extension/identifier_extension.dart';
import '../model/super_field_declaration.dart';

Future<List<SuperFieldDeclaration>> superizeFieldDeclarations(DeclarationPhaseIntrospector builder, List<FieldDeclaration> fields) {
  return Future.wait(fields.map((FieldDeclaration field) => superizeFieldDeclaration(builder, field)));
}

Future<SuperFieldDeclaration> superizeFieldDeclaration(DeclarationPhaseIntrospector builder, FieldDeclaration field) async {
  final TypeDeclaration? realType = await field.identifier.realType(builder);
  return SuperFieldDeclaration(
    original: field,
    realType: realType,
  );
}

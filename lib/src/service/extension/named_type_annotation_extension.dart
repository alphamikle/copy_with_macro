import 'package:macros/macros.dart';

import 'macro_extensions.dart';

extension ExtendedNamedTypeAnnotation on NamedTypeAnnotation {
  Future<ClassDeclaration?> classDeclaration(DefinitionBuilder builder) async {
    final TypeDeclaration? declaration = await realDeclarationOf(builder);
    if (declaration is! ClassDeclaration) {
      // builder.logInfo('Only classes are supported as field types for serializable classes');
      return null;
    }
    return declaration;
  }

  Future<TypeDeclaration?> realDeclarationOf(DefinitionBuilder builder) async {
    TypeDeclaration declaration = await builder.typeDeclarationOf(identifier);
    while (declaration is TypeAliasDeclaration) {
      final TypeAnnotation aliasedType = declaration.aliasedType;
      if (aliasedType is! NamedTypeAnnotation) {
        builder.logInfo('Only fields with named types are allowed on serializable classes');
        return null;
      }
      declaration = await builder.typeDeclarationOf(aliasedType.identifier);
    }
    return declaration;
  }
}

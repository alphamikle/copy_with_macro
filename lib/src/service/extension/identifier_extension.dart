import 'package:macros/macros.dart';

import 'macro_extensions.dart';

extension ExtendedIdentifier on Identifier {
  Future<TypeDeclaration?> realType(DeclarationPhaseIntrospector builder) async {
    void log(String error) {
      if (builder is Builder) {
        (builder as Builder).logInfo(error);
      }
    }

    try {
      TypeDeclaration declaration = await builder.typeDeclarationOf(this);
      while (declaration is TypeAliasDeclaration) {
        final TypeAnnotation aliasedType = declaration.aliasedType;
        if (aliasedType is! NamedTypeAnnotation) {
          log('Only named types allowed. Field name: "$name"');
          return null;
        }
        declaration = await builder.typeDeclarationOf(aliasedType.identifier);
      }
      return declaration;
    } catch (error, stackTrace) {
      log('Error on getting real type: $error; Stack trace: ${stackTrace.toString()}');
    }
    return null;
  }
}

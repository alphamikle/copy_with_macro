import 'package:macros/macros.dart';

import '../../domain/class_info/logic/model/class_info.dart';
import 'macro_extensions.dart';
import 'named_type_annotation_extension.dart';

extension ExtendedFormalParameterDeclaration on FormalParameterDeclaration {
  TypeAnnotationCode notOmittedTypeCode(ClassInfo classInfo, Builder builder) {
    if (type.code is OmittedTypeAnnotationCode) {
      final TypeAnnotationCode? typedCode = classInfo.types[identifier.name];
      if (typedCode == null) {
        builder.logInfo('Field "${identifier.name}" has no type info');
      }
      return typedCode ?? type.code;
    }
    return type.code;
  }
}

extension ExtendedFormalParameterDeclarationList on List<FormalParameterDeclaration> {
  List<FormalParameterDeclaration> nullableOnly(ClassInfo classInfo, Builder builder) {
    return where((FormalParameterDeclaration it) {
      final TypeAnnotationCode notOmittedType = it.notOmittedTypeCode(classInfo, builder);
      return notOmittedType.isNullable;
    }).toList();
  }

  Future<List<EnumDeclaration>> enumOnly(ClassInfo classInfo, DefinitionBuilder builder) async {
    final List<EnumDeclaration> enums = [];
    for (int i = 0; i < length; i++) {
      final declaration = this[i];

      if (declaration.type is NamedTypeAnnotation) {
        final TypeDeclaration? realDeclaration = await (declaration.type as NamedTypeAnnotation).realDeclarationOf(builder);
        if (realDeclaration is EnumDeclaration) {
          enums.add(realDeclaration);
        }
      }
    }
    return enums;
  }
}

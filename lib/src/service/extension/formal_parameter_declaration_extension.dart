import 'package:macros/macros.dart';

import '../../domain/class_info/logic/model/class_info.dart';
import 'macro_extensions.dart';

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
}

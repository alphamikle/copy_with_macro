import 'package:macros/macros.dart';

import '../logic_old/macro_extensions.dart';
import 'class_info.dart';

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
  List<FormalParameterDeclaration> get nullableOnly {
    return where((FormalParameterDeclaration it) => it.type.isNullable).toList();
  }
}

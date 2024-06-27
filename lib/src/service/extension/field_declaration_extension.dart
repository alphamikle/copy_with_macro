import 'package:macros/macros.dart';

import '../../domain/class_info/logic/model/class_info.dart';
import 'macro_extensions.dart';

extension ExtendedFieldDeclaration on FieldDeclaration {
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

extension ExtendedFieldDeclarationList on List<FieldDeclaration> {
  List<FieldDeclaration> nullableOnly(ClassInfo classInfo, Builder builder) {
    return where((FieldDeclaration it) {
      final TypeAnnotationCode notOmittedType = it.notOmittedTypeCode(classInfo, builder);
      return notOmittedType.isNullable;
    }).toList();
  }
}

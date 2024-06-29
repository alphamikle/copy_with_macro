import 'package:macros/macros.dart';

import '../../domain/class_info/logic/model/class_info.dart';
import '../../domain/class_info/logic/model/super_field_declaration.dart';
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

extension ExtendedFieldDeclarationList on List<SuperFieldDeclaration> {
  List<SuperFieldDeclaration> nullableOnly(ClassInfo classInfo, Builder builder) {
    return where((SuperFieldDeclaration it) {
      final TypeAnnotationCode notOmittedType = it.original.notOmittedTypeCode(classInfo, builder);
      return notOmittedType.isNullable;
    }).toList();
  }
}

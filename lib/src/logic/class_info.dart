import 'package:macros/macros.dart';

import 'class_type.dart';

class ClassInfo {
  const ClassInfo({
    required this.declaration,
    required this.inheritance,
    required this.structure,
    required this.fields,
    this.constructor,
    this.superInfo,
  }) : assert(inheritance == ClassInheritance.firstborn && superInfo == null || inheritance == ClassInheritance.successor && superInfo != null);

  final ClassDeclaration declaration;
  final ClassInheritance inheritance;
  final ClassStructure structure;
  final List<FieldDeclaration> fields;
  final ConstructorDeclaration? constructor;
  final ClassInfo? superInfo;

  String get name => declaration.identifier.name;

  ClassInfo copyWith({
    ClassDeclaration? declaration,
    ClassInheritance? inheritance,
    ClassStructure? structure,
    List<FieldDeclaration>? fields,
    ConstructorDeclaration? constructor,
    ClassInfo? superInfo,
  }) {
    return ClassInfo(
      declaration: declaration ?? this.declaration,
      inheritance: inheritance ?? this.inheritance,
      structure: structure ?? this.structure,
      fields: fields ?? this.fields,
      constructor: constructor ?? this.constructor,
      superInfo: superInfo ?? this.superInfo,
    );
  }
}

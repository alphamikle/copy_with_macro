import 'package:macros/macros.dart';

import 'class_type.dart';

class ClassInfo {
  const ClassInfo({
    required this.declaration,
    required this.inheritance,
    required this.structure,
    required this.fields,
    required this.types,
    this.constructor,
    this.superInfo,
  }) : assert(inheritance == ClassInheritance.firstborn && superInfo == null || inheritance == ClassInheritance.successor && superInfo != null);

  final ClassDeclaration declaration;
  final ClassInheritance inheritance;
  final ClassStructure structure;
  final List<FieldDeclaration> fields;
  final Map<String, TypeAnnotationCode> types;
  final ConstructorDeclaration? constructor;
  final ClassInfo? superInfo;

  String get name => declaration.identifier.name;

  bool get hasSuper => superInfo != null;

  bool get hasConstructor => constructor != null;

  bool get hasArguments => hasConstructor && (posArguments.isNotEmpty || namedArguments.isNotEmpty);

  List<FieldDeclaration> get superFields => superInfo?.fields ?? <FieldDeclaration>[];

  List<FieldDeclaration> get allFields {
    final Set<FieldDeclaration> fields = {};
    fields.addAll(this.fields);
    if (superInfo != null) {
      fields.addAll(superInfo!.fields);
    }
    return fields.toList();
  }

  List<FormalParameterDeclaration> get posArguments => constructor?.positionalParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get namedArguments => constructor?.namedParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get superPosArguments => superInfo?.constructor?.positionalParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get superNamedArguments => superInfo?.constructor?.namedParameters.toList() ?? <FormalParameterDeclaration>[];

  ClassInfo copyWith({
    ClassDeclaration? declaration,
    ClassInheritance? inheritance,
    ClassStructure? structure,
    List<FieldDeclaration>? fields,
    Map<String, TypeAnnotationCode>? types,
    ConstructorDeclaration? constructor,
    ClassInfo? superInfo,
  }) {
    return ClassInfo(
      declaration: declaration ?? this.declaration,
      inheritance: inheritance ?? this.inheritance,
      structure: structure ?? this.structure,
      fields: fields ?? this.fields,
      types: types ?? this.types,
      constructor: constructor ?? this.constructor,
      superInfo: superInfo ?? this.superInfo,
    );
  }
}

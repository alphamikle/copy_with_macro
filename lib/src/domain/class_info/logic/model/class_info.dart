import 'package:macros/macros.dart';

import 'class_type.dart';
import 'super_field_declaration.dart';

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
  final List<SuperFieldDeclaration> fields;
  final Map<String, TypeAnnotationCode> types;
  final ConstructorDeclaration? constructor;
  final ClassInfo? superInfo;

  Identifier get identifier => declaration.identifier;

  String get name => identifier.name;

  bool get hasSuper => superInfo != null;

  bool get hasConstructor => constructor != null;

  bool get hasArguments => hasConstructor && (posArguments.isNotEmpty || namedArguments.isNotEmpty);

  List<SuperFieldDeclaration> get superFields => superInfo?.fields ?? <SuperFieldDeclaration>[];

  List<SuperFieldDeclaration> get allFields {
    final Set<SuperFieldDeclaration> fields = {};
    fields.addAll(this.fields);
    if (superInfo != null) {
      fields.addAll(superInfo!.fields);
    }
    return fields.toList();
  }

  List<FormalParameterDeclaration> get posArguments => constructor?.positionalParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get namedArguments => constructor?.namedParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get arguments => [...posArguments, ...namedArguments];

  List<FormalParameterDeclaration> get superPosArguments => superInfo?.constructor?.positionalParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get superNamedArguments => superInfo?.constructor?.namedParameters.toList() ?? <FormalParameterDeclaration>[];

  List<FormalParameterDeclaration> get allSuperArguments => [...superPosArguments, ...superNamedArguments];

  ClassInfo copyWith({
    ClassDeclaration? declaration,
    ClassInheritance? inheritance,
    ClassStructure? structure,
    List<SuperFieldDeclaration>? fields,
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

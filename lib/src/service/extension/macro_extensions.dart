import 'package:macros/macros.dart';

import 'common_extensions.dart';

typedef FieldName = String;
typedef FieldInfo = ({FieldName name, bool required, bool nullable, TypeAnnotation? type});
typedef ConstructorArgumentsInfo = ({Set<FieldInfo> positionalFields, Set<FieldInfo> namedFields, Set<FieldName> usedNames});

extension ExtendedDeclarationPhaseIntrospector on DeclarationPhaseIntrospector {
  Future<ConstructorDeclaration?> constructorOf(TypeDeclaration type, {String name = ''}) async {
    final List<ConstructorDeclaration> constructors = await constructorsOf(type);
    if (constructors.isEmpty) {
      return null;
    }
    final ConstructorDeclaration? target = constructors.firstWhereOrNull((ConstructorDeclaration it) => it.identifier.name == name);
    return target;
  }

  Future<ClassDeclaration?> superOf(ClassDeclaration cla2s) async {
    if (cla2s.superclass == null) {
      return null;
    }
    final TypeDeclaration superConstructor = await typeDeclarationOf(cla2s.superclass!.identifier);
    return superConstructor is ClassDeclaration ? superConstructor : null;
  }

  Future<ConstructorArgumentsInfo> constructorArgumentsOf(ClassDeclaration cla2s, {String name = ''}) async {
    final ConstructorDeclaration? constructor = await constructorOf(cla2s, name: name);
    final Map<FieldName, FieldInfo> positionalFields = {};
    final Map<FieldName, FieldInfo> namedFields = {};
    final Set<FieldName> usedNames = {};

    for (final FormalParameterDeclaration field in constructor?.positionalParameters ?? <FormalParameterDeclaration>[]) {
      usedNames.add(field.name);
      positionalFields[field.name] = (name: field.name, required: field.isRequired, nullable: field.type.isNullable, type: field.type);
    }

    for (final FormalParameterDeclaration field in constructor?.namedParameters ?? <FormalParameterDeclaration>[]) {
      usedNames.add(field.name);
      namedFields[field.name] = (name: field.name, required: field.isRequired, nullable: field.type.isNullable, type: field.type);
    }

    return (positionalFields: {...positionalFields.values}, namedFields: {...namedFields.values}, usedNames: usedNames);
  }

  Future<ConstructorArgumentsInfo> methodArgumentsOf(ClassDeclaration cla2s, String methodName) async {
    final List<MethodDeclaration> methods = await methodsOf(cla2s);
    final MethodDeclaration? method = methods.firstWhereOrNull((it) => it.identifier.name == methodName);
    if (method == null) {
      throw Exception('Not found method "$methodName"');
    }
    final Set<FieldName> usedNames = {};
    final Set<FieldInfo> positionalFields = {};
    final Set<FieldInfo> namedFields = {};

    for (final param in method.positionalParameters) {
      usedNames.add(param.identifier.name);
      positionalFields.add((name: param.identifier.name, required: param.isRequired, nullable: param.type.isNullable, type: param.type));
    }

    for (final param in method.namedParameters) {
      usedNames.add(param.identifier.name);
      if (this is Builder) {
        (this as Builder).logInfo('''
Param:
${param.name}
>>>
${param.type.as<NamedTypeAnnotation>().identifier.name}
''');
      }
      namedFields.add((name: param.identifier.name, required: param.isRequired, nullable: param.type.isNullable, type: param.type));
    }

    return (positionalFields: positionalFields, namedFields: namedFields, usedNames: usedNames);
  }

  Future<ConstructorArgumentsInfo> argumentsOf(ClassDeclaration cla2s, {String name = ''}) async {
    final (namedFields: namedFields, positionalFields: positionalFields, usedNames: usedNames) = await constructorArgumentsOf(cla2s, name: name);

    final List<FieldDeclaration> fields = await fieldsOf(cla2s);

    for (final FieldDeclaration field in fields) {
      if (usedNames.contains(field.identifier.name) == false) {
        usedNames.add(field.identifier.name);
        namedFields.add((name: field.identifier.name, required: true, nullable: field.type.isNullable, type: field.type));
      }
    }

    return (positionalFields: positionalFields, namedFields: namedFields, usedNames: usedNames);
  }

  Future<List<FieldDeclaration>> allFieldsOf(ClassDeclaration cla2s) async {
    final List<FieldDeclaration> fields = await fieldsOf(cla2s);
    ClassDeclaration? superClass = await superOf(cla2s);

    while (superClass != null) {
      fields.addAll(await fieldsOf(superClass));
      superClass = await superOf(superClass);
    }

    return fields;
  }
}

extension ExtendedMacroBuilder on Builder {
  void logInfo(String message) {
    report(
      Diagnostic(
        DiagnosticMessage(message),
        Severity.info,
      ),
    );
  }
}

extension ExtendedFieldsDeclarations on Iterable<FieldDeclaration> {
  bool isProperlyTyped(Builder builder) {
    bool allFieldsAreCorrect = true;

    for (final field in this) {
      final bool isCorrect = field.type.guardNamedType(field.identifier.name, builder);
      if (isCorrect == false) {
        allFieldsAreCorrect = false;
      }
    }

    return allFieldsAreCorrect;
  }
}

extension ExtendedTypeAnnotation on TypeAnnotation {
  T as<T extends TypeAnnotation>() {
    if (this is T) {
      return this as T;
    }
    throw ArgumentError('Value of type "$runtimeType" is not as requested type "$T"');
  }

  bool guardNamedType(FieldName fieldName, Builder builder) {
    if (this is NamedTypeAnnotation) {
      return true;
    }
    if (this is OmittedTypeAnnotation) {
      builder.logInfo('Field $fieldName should have explicit type');
    } else {
      builder.logInfo('Field $fieldName should have named type');
    }
    return false;
  }

  bool get isNonNullable {
    return isNullable == false;
  }
}

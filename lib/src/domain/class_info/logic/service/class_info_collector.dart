import 'package:macros/macros.dart';

import '../../../../service/extension/macro_extensions.dart';
import '../model/class_info.dart';
import '../model/class_type.dart';

class ClassInfoCollector {
  ClassInfoCollector({
    required ClassDeclaration clazz,
    required String constructorName,
  })  : _constructorName = constructorName,
        _clazz = clazz;

  final ClassDeclaration _clazz;
  final String _constructorName;

  ClassInfo? _classInfo;

  ClassInfo get classInfo {
    if (_classInfo == null) {
      throw Exception('Run "collect" method first');
    }
    return _classInfo!;
  }

  Future<void> collect(DeclarationPhaseIntrospector builder) async {
    _classInfo = await _collect(_clazz, builder, 0);
  }

  Future<ClassInfo> _collect(ClassDeclaration clazz, DeclarationPhaseIntrospector builder, int level) async {
    final ClassInheritance inheritance;
    final ClassStructure structure;
    final ClassDeclaration? superClass = await builder.superOf(clazz);
    if (superClass == null) {
      inheritance = ClassInheritance.firstborn;
    } else {
      inheritance = ClassInheritance.successor;
    }

    final ConstructorDeclaration? constructor = await builder.constructorOf(clazz, name: _constructorName);
    final List<FieldDeclaration> fields = await builder.fieldsOf(clazz);

    structure = switch ((constructor == null, fields.isEmpty)) {
      (true, true) => ClassStructure.empty,
      (true, false) => ClassStructure.hasFields,
      (false, true) => ClassStructure.hasConstructor,
      (false, false) => ClassStructure.hasFieldsAndConstructor,
    };

    final ClassInfo classInfo = ClassInfo(
      declaration: clazz,
      inheritance: inheritance,
      structure: structure,
      fields: fields,
      constructor: constructor,
      superInfo: superClass == null ? null : await _collect(superClass, builder, level + 1),
      types: const {},
    );

    if (level > 0) {
      return classInfo;
    }

    final List<FieldDeclaration> allFields = classInfo.allFields;
    final Map<String, TypeAnnotationCode> types = {};

    for (final field in allFields) {
      types[field.identifier.name] = field.type.code;
    }

    assert(allFields.length == types.length);

    return classInfo.copyWith(types: types);
  }
}

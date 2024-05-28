import 'package:macros/macros.dart';

import 'class_info.dart';
import 'class_info_collector.dart';

mixin ClassInfoMixin {
  String get name;

  Future<ClassInfo> collectClassInfo({
    required ClassDeclaration clazz,
    required DeclarationPhaseIntrospector builder,
  }) async {
    final ClassInfoCollector collector = ClassInfoCollector(clazz: clazz, constructorName: name);
    await collector.collect(builder);
    return collector.classInfo;
  }
}

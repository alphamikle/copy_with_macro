import 'package:macros/macros.dart';

import '../model/class_info.dart';
import '../service/class_info_collector.dart';

mixin ClassInfoMixin {
  String get name;

  String get cName {
    if (name == '') {
      return '';
    }
    return '.$name';
  }

  Future<ClassInfo> collectClassInfo({
    required ClassDeclaration clazz,
    required DeclarationPhaseIntrospector builder,
    String? nameOverride,
  }) async {
    final ClassInfoCollector collector = ClassInfoCollector(clazz: clazz, constructorName: nameOverride ?? name);
    await collector.collect(builder);
    return collector.classInfo;
  }
}

import 'package:macros/macros.dart';

import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';

mixin SerializableToJsonTypeMixin on ClassInfoMixin {
  Future<void> buildType(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    final Identifier toJsonAbleInterface = await builder.resolveIdentifier(toJsonAbleInterfaceLibrary, 'ToJsonAble');
    final NamedTypeAnnotationCode toJsonAbleInterfaceCode = NamedTypeAnnotationCode(name: toJsonAbleInterface);
    builder.appendInterfaces([toJsonAbleInterfaceCode]);
  }
}

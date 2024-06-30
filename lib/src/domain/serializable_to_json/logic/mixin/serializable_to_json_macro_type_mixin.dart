import 'package:macros/macros.dart';

import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';

mixin SerializableToJsonTypeMixin on ClassInfoMixin {
  Future<void> buildType(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    final Identifier toJsonAbleId = await builder.resolveId($toJsonable);
    builder.appendInterfaces([NamedTypeAnnotationCode(name: toJsonAbleId)]);
  }
}

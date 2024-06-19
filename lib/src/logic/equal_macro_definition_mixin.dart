import 'package:macros/macros.dart';

import '../logic_old/common_extensions.dart';
import 'class_info.dart';
import 'class_info_mixin.dart';
import 'types.dart';

mixin EqualMacroDefinitionMixin on ClassInfoMixin {
  Future<void> defineOperator(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    // TODO(alphamikle):
  }

  Future<void> defineFields(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final List<MethodDeclaration> methods = await builder.methodsOf(clazz);
    final MethodDeclaration? methodDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == objectFieldsLiteral);

    if (methodDeclaration == null) {
      return;
    }

    final FunctionDefinitionBuilder method = await builder.buildMethod(methodDeclaration.identifier);
    final List<FieldDeclaration> allFields = classInfo.allFields;

    /// ? List<Object?> get $fields => [field1, field2, fieldN];
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      ' => ',
      '[',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
          (int index, FieldDeclaration value) => [
            value.identifier,
            if (i < allFields.length - 1) ', ',
          ],
        ),
      '];',
    ]);
    method.augment(code);
  }

  Future<void> defineHashcode(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    // TODO(alphamikle):
  }
}

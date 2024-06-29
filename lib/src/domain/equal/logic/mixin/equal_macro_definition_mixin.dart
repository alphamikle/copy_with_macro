import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/extension/type_definition_builder_extension.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../class_info/logic/model/super_field_declaration.dart';

mixin EqualMacroDefinitionMixin on ClassInfoMixin {
  Future<void> defineOperator(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? method = await builder.methodBuilderByName(clazz, equalLiteral);
    if (method == null) {
      return;
    }

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final Identifier identicalId = await builder.resolveId($identical);
    final List<SuperFieldDeclaration> allFields = classInfo.allFields;

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '{\n',
      '    if (',
      identicalId,
      '(this, other)) return true;\n'
          '    if (other is ',
      classInfo.identifier,
      ') {\n',
      '      return ',
      if (allFields.isEmpty)
        ' $hashCodeLiteral == other.$hashCodeLiteral'
      else
        for (int i = 0; i < allFields.length; i++)
          ...i.spread(
            allFields,
            (int index, SuperFieldDeclaration value) => [
              value.identifier.name,
              ' == ',
              'other.${value.identifier.name}',
              ' && ',
            ],
          ),
      '$hashCodeLiteral == other.$hashCodeLiteral',
      ';\n',
      '    }\n',
      '    return false;\n',
      '  }',
    ]);
    method.augment(code);
  }

  /// List<Object?> get $fields => [field1, field2, fieldN];
  Future<void> defineFields(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? method = await builder.methodBuilderByName(clazz, objectFieldsLiteral);
    if (method == null) {
      return;
    }

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final List<SuperFieldDeclaration> allFields = classInfo.allFields;

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      ' => ',
      '[',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
          (int index, SuperFieldDeclaration value) => [
            value.identifier,
            if (i < allFields.length - 1) ', ',
          ],
        ),
      '];',
    ]);
    method.augment(code);
  }

  /// int get hashCode => hashObjects($fields);
  Future<void> defineHashcode(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? method = await builder.methodBuilderByName(clazz, hashCodeLiteral);
    if (method == null) {
      builder.logInfo('Not found $method');
      return;
    }

    final Identifier hashObjectsId = await builder.resolveId($hashObjects);
    final NamedTypeAnnotationCode hashObjectsFunctionCode = NamedTypeAnnotationCode(name: hashObjectsId);

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      ' => ',
      hashObjectsFunctionCode,
      '($objectFieldsLiteral);',
    ]);
    method.augment(code);
  }
}

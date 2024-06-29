import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/formal_parameter_declaration_extension.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/extension/type_definition_builder_extension.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../interface/serializable_to_json_interface.dart';

typedef Mapper = String Function(Object part);

Mapper partToString(TypeDefinitionBuilder builder) {
  String mapper(Object part) {
    if (part is Identifier) {
      return part.name;
    }
    return part.toString();
  }

  return mapper;
}

mixin FromJsonDefinitionMixin on ClassInfoMixin implements SerializableToJsonInterface {
  Future<void> defineFromJson(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? factoryConstructor = await builder.methodBuilderByName(clazz, fromJsonLiteral);
    if (factoryConstructor == null) {
      builder.logInfo('Not found $fromJsonLiteral');
      return;
    }

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final List<FormalParameterDeclaration> constructorArguments = classInfo.arguments;
    final List<EnumDeclaration> enumArguments = await constructorArguments.enumOnly(classInfo, builder);

    final Identifier mapId = await builder.resolveId($map);
    final Identifier stringId = await builder.resolveId($string);
    final Identifier caseConverterId = await builder.resolveId($caseConverter);
    final Identifier mapEntryId = await builder.resolveId($mapEntry);
    final Identifier namingStrategyId = await builder.resolveId($namingStrategy);

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '{\n',
      for (int i = 0; i < enumArguments.length; i++)
        ...i.spread(
          enumArguments,
          (int index, EnumDeclaration value) => [
            ..._buildEnumFromJsonMap(
              declaration: value,
              mapId: mapId,
              mapEntryId: mapEntryId,
              caseConverterId: caseConverterId,
              stringId: stringId,
              namingStrategyId: namingStrategyId,
            ),
          ],
        ),
      '    return ${classInfo.name}.\$$fromJsonLiteral(\n',
      for (int i = 0; i < constructorArguments.length; i++)
        ...i.spread(
          constructorArguments,
          (int index, FormalParameterDeclaration value) => [
            "      ${value.name}: json[r'${toCase(value.name)}'] as ",
            value.type.code,
            ',\n',
          ],
        ),
      '    );\n',
      '  }',
    ]);
    factoryConstructor.augment(code);
  }

  /// ? double
  /// ? int
  /// ? string
  /// ? bool
  /// ? null
  /// ? List
  /// ? Set
  /// ? Map
  /// ? tuple () + ({})
  /// ? DateTime
  /// ? Duration
  /// ? Color
  /// ? Class
  /// ? Enum
  List<Object> _buildEnumFromJsonMap({
    required EnumDeclaration declaration,
    required Identifier mapId,
    required Identifier stringId,
    required Identifier caseConverterId,
    required Identifier mapEntryId,
    required Identifier namingStrategyId,
  }) {
    return [
      '    final ',
      mapId,
      '<',
      stringId,
      ', ',
      declaration.identifier,
      '>',
      ' stringTo${declaration.identifier.name} = ',
      declaration.identifier,
      '.values.asNameMap().map((key, value) => ',
      mapEntryId,
      '(',
      caseConverterId,
      '(key, ',
      namingStrategyId,
      '.',
      strategy.name,
      '), value));\n',
    ];
  }
}

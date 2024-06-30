import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/extension/type_definition_builder_extension.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../interface/serializable_to_json_interface.dart';
import '../model/formal_parameter_declaration_info.dart';
import '../service/field_json_converter.dart';
import '../service/formal_parameter_declaration_info_collector.dart';
import '../service/from_json/field_from_json_converter.dart';

mixin FromJsonDefinitionMixin on ClassInfoMixin implements SerializableToJsonInterface {
  Future<void> defineFromJson(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? factoryConstructor = await builder.methodBuilderByName(clazz, fromJsonLiteral);
    if (factoryConstructor == null) {
      builder.logInfo('Not found $fromJsonLiteral');
      return;
    }

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final List<FormalParameterDeclaration> constructorArguments = classInfo.arguments;

    final FormalParameterDeclarationInfoCollector infoCollector = FormalParameterDeclarationInfoCollector(builder: builder);
    final List<FormalParameterDeclarationInfo> extraArguments = await infoCollector.collect(constructorArguments);

    final [
      Identifier mapId,
      Identifier stringId,
      Identifier caseConverterId,
      Identifier mapEntryId,
      Identifier namingStrategyId,
    ] = await builder.resolveIds([
      $map,
      $string,
      $caseConverter,
      $mapEntry,
      $namingStrategy,
    ]);

    final List<FieldFromJsonConverter> converters = [];

    for (final extraArgument in extraArguments) {
      FieldFromJsonConverter? converter;

      for (final factory in fromJson) {
        final FieldFromJsonConverter tempConverter = factory(classInfo: classInfo, fieldInfo: extraArgument, builder: builder, caseConverter: toCase);

        // builder.logInfo('Converter for "${extraArgument.name}": ${tempConverter.canProduceCode()}');

        if (tempConverter.canProduceCode()) {
          converter = tempConverter;
          continue;
        }
      }

      if (converter == null) {
        builder.logInfo('Not found the right fromJson converter for field "${extraArgument.name}"');
      } else {
        converters.add(converter);
      }
    }

    final Identifiers identifiers = (
      map: mapId,
      string: stringId,
      caseConverter: caseConverterId,
      mapEntry: mapEntryId,
      namingStrategy: namingStrategyId,
      strategy: strategy,
    );

    final List<List<Object>> preConstructorCode = await Future.wait(converters.map((FieldFromJsonConverter it) async => it.preConstructorCode(identifiers)));
    final List<List<Object>> argumentCode = await Future.wait(converters.map((FieldFromJsonConverter it) async => it.argumentCode(identifiers)));

    // builder.logInfo(argumentCode.join(';'));

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '{\n',
      for (int i = 0; i < preConstructorCode.length; i++)
        ...i.spread(
          preConstructorCode,
          (int index, List<Object> value) => value,
        ),
      '    return ${classInfo.name}.\$$fromJsonLiteral(\n',
      for (int i = 0; i < argumentCode.length; i++)
        ...i.spread(
          argumentCode,
          (int index, List<Object> value) => value,
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
}

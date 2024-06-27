import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/extension/type_definition_builder_extension.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../converter/names_converter.dart';
import '../interface/serializable_to_json_interface.dart';
import '../macro/serializable_to_json_macro.dart';

mixin SerializableToJsonDefinitionMixin on ClassInfoMixin implements SerializableToJsonInterface {
  Future<void> defineFromJson(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final FunctionDefinitionBuilder? factoryConstructor = await builder.methodBuilderByName(clazz, fromJsonLiteral);
    if (factoryConstructor == null) {
      builder.logInfo('Not found $fromJsonLiteral');
      return;
    }

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final List<FormalParameterDeclaration> constructorArguments = classInfo.arguments;

    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      '{\n',
      '    return ${classInfo.name}.\$$fromJsonLiteral(\n',
      for (int i = 0; i < constructorArguments.length; i++)
        ...i.spread(
          constructorArguments,
          (int index, FormalParameterDeclaration value) => [
            "      ${value.name}: json[r'${_nameTransformer(value.name)}'] as ",
            value.type.code,
            ',\n',
          ],
        ),
      '    );\n',
      '  }',
    ]);
    factoryConstructor.augment(code);
  }

  String _nameTransformer(String variableName) {
    final NamingStrategy strategy = this.strategy;
    return switch (strategy) {
      NamingStrategy.camel => variableName.asCamelCase,
      NamingStrategy.pascal => variableName.asPascalCase,
      NamingStrategy.snake => variableName.asSnakeCase,
      NamingStrategy.screamingSnake => variableName.asScreamingSnakeCase,
      NamingStrategy.kebab => variableName.asKebabCase,
      NamingStrategy.train => variableName.asTrainCase,
      NamingStrategy.dot => variableName.asDotCase,
    };
  }

  Future<void> defineToJson(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    // TODO(alphamikle):
  }
}

import 'package:macros/macros.dart';

import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../with_constructor/logic/mixin/with_constructor_macro_declaration_mixin.dart';

mixin SerializableToJsonDeclarationMixin on ClassInfoMixin, WithConstructorDeclarationMixin {
  Future<void> declareFromJson(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await buildDeclaration(clazz, builder);

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final Identifier mapId = await builder.resolveId($map);
    final Identifier stringId = await builder.resolveId($string);
    final Identifier dynamicId = await builder.resolveId($dynamic);

    // external factory Clazz.fromJson(Map<String, dynamic> json);
    final DeclarationCode code = DeclarationCode.fromParts([
      '  external static ${classInfo.name} $fromJsonLiteral(',
      mapId,
      '<',
      stringId,
      ', ',
      dynamicId,
      '> json);',
    ]);
    builder.declareInType(code);
  }

  Future<void> declareToJson(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier mapId = await builder.resolveId($map);
    final Identifier stringId = await builder.resolveId($string);
    final Identifier dynamicId = await builder.resolveId($dynamic);

    // external Map<String, dynamic> toJson();
    final DeclarationCode code = DeclarationCode.fromParts([
      '  external ',
      mapId,
      '<',
      stringId,
      ', ',
      dynamicId,
      '> $toJsonLiteral();',
    ]);
    builder.declareInType(code);
  }
}

/*
static const Map<String, String> constants = const {
  'first': 'Hello!',
};
 */

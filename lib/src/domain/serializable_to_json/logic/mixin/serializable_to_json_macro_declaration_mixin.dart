import 'package:macros/macros.dart';

import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';
import '../../../with_constructor/logic/mixin/with_constructor_macro_declaration_mixin.dart';

mixin SerializableToJsonDeclarationMixin on ClassInfoMixin, WithConstructorDeclarationMixin {
  Future<void> declareFromJson(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await buildDeclaration(clazz, builder);

    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final Identifier coreMap = await builder.resolveIdentifier(dartCorePackage, 'Map');
    final Identifier coreString = await builder.resolveIdentifier(dartCorePackage, 'String');
    final Identifier coreDynamic = await builder.resolveIdentifier(dartCorePackage, 'dynamic');

    // external factory Clazz.fromJson(Map<String, dynamic> json);
    final DeclarationCode code = DeclarationCode.fromParts([
      '  external static ${classInfo.name} $fromJsonLiteral(',
      coreMap,
      '<',
      coreString,
      ', ',
      coreDynamic,
      '> json);',
    ]);
    builder.declareInType(code);
  }

  Future<void> declareToJson(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreMap = await builder.resolveIdentifier(dartCorePackage, 'Map');
    final Identifier coreString = await builder.resolveIdentifier(dartCorePackage, 'String');
    final Identifier coreDynamic = await builder.resolveIdentifier(dartCorePackage, 'dynamic');

    // external Map<String, dynamic> toJson();
    final DeclarationCode code = DeclarationCode.fromParts([
      '  external ',
      coreMap,
      '<',
      coreString,
      ', ',
      coreDynamic,
      '> $toJsonLiteral();',
    ]);
    builder.declareInType(code);
  }
}

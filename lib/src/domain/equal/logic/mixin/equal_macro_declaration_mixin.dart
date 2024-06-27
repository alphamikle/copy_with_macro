import 'package:macros/macros.dart';

import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';

mixin EqualMacroDeclarationMixin on ClassInfoMixin {
  Future<void> declareOperator(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreObject = await builder.resolveIdentifier(dartCorePackage, 'Object');
    final Identifier coreBool = await builder.resolveIdentifier(dartCorePackage, 'bool');

    /// ? external bool operator==(Object? other);
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        coreBool,
        ' operator$equalLiteral(',
        coreObject,
        ' other',
        ');',
      ],
    );
    builder.declareInType(declaration);
  }

  Future<void> declareFields(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreList = await builder.resolveIdentifier(dartCorePackage, 'List');
    final Identifier coreObject = await builder.resolveIdentifier(dartCorePackage, 'Object');

    /// ? external List<Object?> get props;
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        coreList,
        '<',
        coreObject,
        '?>',
        ' get ',
        objectFieldsLiteral,
        ';',
      ],
    );
    builder.declareInType(declaration);
  }

  Future<void> declareHashcode(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreInt = await builder.resolveIdentifier(dartCorePackage, 'int');

    /// ? external int get hashCode;
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        coreInt,
        ' get ',
        hashCodeLiteral,
        ';',
      ],
    );
    builder.declareInType(declaration);
  }
}

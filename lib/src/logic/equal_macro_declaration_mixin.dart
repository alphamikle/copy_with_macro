import 'package:macros/macros.dart';

import 'class_info_mixin.dart';
import 'types.dart';

mixin EqualMacroDeclarationMixin on ClassInfoMixin {
  Future<void> declareOperator(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreObject = await builder.resolveIdentifier(dartCodePackage, 'Object');
    final Identifier coreBool = await builder.resolveIdentifier(dartCodePackage, 'bool');

    /// ? external bool operator==(Object? other);
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        coreBool,
        ' operator$equalLiteral(',
        coreObject,
        '?',
        ' other',
        ');',
      ],
    );
    builder.declareInType(declaration);
  }

  Future<void> declareFields(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier coreList = await builder.resolveIdentifier(dartCodePackage, 'List');
    final Identifier coreObject = await builder.resolveIdentifier(dartCodePackage, 'Object');

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
    final Identifier coreInt = await builder.resolveIdentifier(dartCodePackage, 'int');

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

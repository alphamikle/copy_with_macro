import 'package:macros/macros.dart';

import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';

mixin EqualMacroDeclarationMixin on ClassInfoMixin {
  Future<void> declareOperator(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier objectId = await builder.resolveId($object);
    final Identifier boolId = await builder.resolveId($bool);

    /// ? external bool operator==(Object? other);
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        boolId,
        ' operator$equalLiteral(',
        objectId,
        ' other',
        ');',
      ],
    );
    builder.declareInType(declaration);
  }

  Future<void> declareFields(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier listId = await builder.resolveId($list);
    final Identifier objectId = await builder.resolveId($object);

    /// ? external List<Object?> get props;
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        listId,
        '<',
        objectId,
        '?>',
        ' get ',
        objectFieldsLiteral,
        ';',
      ],
    );
    builder.declareInType(declaration);
  }

  Future<void> declareHashcode(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier intId = await builder.resolveId($int);

    /// ? external int get hashCode;
    final DeclarationCode declaration = DeclarationCode.fromParts(
      [
        '  external ',
        intId,
        ' get ',
        hashCodeLiteral,
        ';',
      ],
    );
    builder.declareInType(declaration);
  }
}

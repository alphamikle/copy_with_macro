import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/extension/common_extensions.dart';
import '../../../../service/extension/identifiers.dart';
import '../../../../service/extension/macro_extensions.dart';
import '../../../../service/extension/type_definition_builder_extension.dart';
import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../class_info/logic/model/class_info.dart';

macro

class Printable with ClassInfoMixin implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const Printable({
    this.asJson = false,
  });

  final bool asJson;

  @override
  String get name => '';

  /// external String toString();
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final Identifier stringId = await builder.resolveId($string);
    final DeclarationCode code = DeclarationCode.fromParts([
      '  external ',
      stringId,
      ' $toStringLiteral();',
    ]);
    builder.declareInType(code);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final ClassInfo classInfo = await collectClassInfo(clazz: clazz, builder: builder);
    final FunctionDefinitionBuilder? method = await builder.methodBuilderByName(clazz, toStringLiteral);
    if (method == null) {
      return;
    }
    final List<FieldDeclaration> allFields = classInfo.allFields;
    final FunctionBodyCode code = FunctionBodyCode.fromParts([
      ' => \'${classInfo.name}(',
      for (int i = 0; i < allFields.length; i++)
        ...i.spread(
          allFields,
              (int index, FieldDeclaration value) =>
          [
            value.identifier.name,
            if (value.type.isNullable) '?',
            r': ${',
            value.identifier,
            '.toString()}',
            if (i < allFields.length - 1) ', ',
          ],
        ),
      ')\'',
      ';',
    ]);
    method.augment(code);
  }
}

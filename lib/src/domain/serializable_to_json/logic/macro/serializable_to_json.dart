import 'dart:async';

import 'package:macros/macros.dart';

import '../service/from_json/common_from_json_converter.dart';
import '../service/from_json/enum_from_json_converter.dart';
import 'basic_serializable_to_json_macro.dart';

macro

class SerializableToJson implements ClassTypesMacro, ClassDeclarationsMacro, ClassDefinitionMacro {
  const SerializableToJson({
    this.namingStrategy = 'plain',
    this.ignorePrivate = false,
  });

  final String namingStrategy;
  final bool ignorePrivate;

  BasicSerializableToJson _basicMacro() {
    return BasicSerializableToJson(
      namingStrategy: namingStrategy,
      ignorePrivate: ignorePrivate,
      fromJson: [
        EnumFromJsonConverter.create,
        CommonFromJsonConverter.create,
      ],
    );
  }

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    await _basicMacro().buildTypesForClass(clazz, builder);
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await _basicMacro().buildDeclarationsForClass(clazz, builder);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    await _basicMacro().buildDefinitionForClass(clazz, builder);
  }
}

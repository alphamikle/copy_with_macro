import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../with_constructor/logic/mixin/with_constructor_macro_declaration_mixin.dart';
import '../converter/names_converter.dart';
import '../interface/serializable_to_json_interface.dart';
import '../mixin/from_json_definition_mixin.dart';
import '../mixin/serializable_to_json_macro_declaration_mixin.dart';
import '../mixin/serializable_to_json_macro_type_mixin.dart';
import '../mixin/to_json_definition_mixin.dart';
import '../service/from_json/field_from_json_converter.dart';
import '../service/to_json/field_to_json_converter.dart';

macro

class BasicSerializableToJson
    with
        ClassInfoMixin,
        WithConstructorDeclarationMixin,
        SerializableToJsonTypeMixin,
        SerializableToJsonDeclarationMixin,
        FromJsonDefinitionMixin,
        ToJsonDefinitionMixin
    implements SerializableToJsonInterface, ClassTypesMacro, ClassDeclarationsMacro, ClassDefinitionMacro {
  const BasicSerializableToJson({
    this.namingStrategy = 'plain',
    this.ignorePrivate = false,
    this.fromJson = const [],
    this.toJson = const [],
  });

  @override
  final String namingStrategy;

  @override
  final bool ignorePrivate;

  @override
  final List<FromJsonConverterFactory> fromJson;

  @override
  final List<ToJsonConverterFactory> toJson;

  @override
  String get name => '\$$fromJsonLiteral';

  @override
  bool get allRequired => true;

  @override
  bool get explicitTypes => true;

  @override
  bool get useNoMethodFoundFix => false;

  @override
  NamingStrategy get strategy => NamingStrategy.fromString(namingStrategy);

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    await buildType(clazz, builder);
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    await [
      declareFromJson(clazz, builder),
      declareToJson(clazz, builder),
    ].wait;
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    await [
      defineFromJson(clazz, builder),
      defineToJson(clazz, builder),
    ].wait;
  }

  @override
  String toCase(String variableName) => toSomeCase(variableName, strategy);
}

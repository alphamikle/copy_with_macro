import 'dart:async';

import 'package:macros/macros.dart';

import '../../../../service/type/types.dart';
import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../../../with_constructor/logic/mixin/with_constructor_macro_declaration_mixin.dart';
import '../interface/serializable_to_json_interface.dart';
import '../mixin/serializable_to_json_macro_declaration_mixin.dart';
import '../mixin/serializable_to_json_macro_definition_mixin.dart';
import '../mixin/serializable_to_json_macro_type_mixin.dart';

enum NamingStrategy {
  // camelCase
  camel,

  // PascalCase
  pascal,

  // snake_case
  snake,

  // SCREAMING_SNAKE_CASE
  screamingSnake,

  // kebab-case
  kebab,

  // Train-Case
  train,

  // dot.case
  dot;

  factory NamingStrategy.fromString(String value) {
    return switch(value) {
      'camel' => NamingStrategy.camel,
      'pascal' => NamingStrategy.pascal,
      'snake' => NamingStrategy.snake,
      'screamingSnake' => NamingStrategy.screamingSnake,
      'kebab' => NamingStrategy.kebab,
      'train' => NamingStrategy.train,
      'dot' => NamingStrategy.dot,
      _ => throw Exception('Not supported Naming Strategy: "$value". Supported values: ${NamingStrategy.values.map((NamingStrategy it) => it.name)}'),
    };
  }
}

macro

class SerializableToJson
    with ClassInfoMixin, WithConstructorDeclarationMixin, SerializableToJsonTypeMixin, SerializableToJsonDeclarationMixin, SerializableToJsonDefinitionMixin
    implements SerializableToJsonInterface, ClassTypesMacro, ClassDeclarationsMacro, ClassDefinitionMacro {
  const SerializableToJson({
    this.namingStrategy = 'snake',
    this.ignorePrivate = false,
  });

  @override
  final String namingStrategy;

  @override
  final bool ignorePrivate;

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
}

import 'dart:async';

import 'package:macros/macros.dart';

import '../../../class_info/logic/model/class_info.dart';
import '../converter/names_converter.dart';
import '../model/formal_parameter_declaration_info.dart';

typedef Identifiers = ({
  Identifier map,
  Identifier string,
  Identifier mapEntry,
  Identifier caseConverter,
  Identifier namingStrategy,
  NamingStrategy strategy,
});

typedef CaseConverter = String Function(String fieldName);

abstract interface class FieldJsonConverter {
  ClassInfo get classInfo;

  FormalParameterDeclarationInfo get fieldInfo;

  TypeDefinitionBuilder get builder;

  CaseConverter get caseConverter;

  FutureOr<List<Object>> preConstructorCode(Identifiers ids);

  FutureOr<List<Object>> argumentCode(Identifiers ids);

  bool canProduceCode();
}

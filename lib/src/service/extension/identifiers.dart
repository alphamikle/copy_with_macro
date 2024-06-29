typedef IdToken = (String url, String name);

const String _core = 'dart:core';
const String _types = 'package:copy_with_macro/src/service/type/types.dart';
const String _serializable = 'package:copy_with_macro/src/domain/serializable_to_json/logic/interface/serializable_to_json_interface.dart';
const String _namesConverter = 'package:copy_with_macro/src/domain/serializable_to_json/logic/converter/names_converter.dart';

const IdToken $bool = (_core, 'bool');
const IdToken $string = (_core, 'String');
const IdToken $object = (_core, 'Object');
const IdToken $list = (_core, 'List');
const IdToken $map = (_core, 'Map');
const IdToken $mapEntry = (_core, 'MapEntry');
const IdToken $int = (_core, 'int');
const IdToken $dynamic = (_core, 'dynamic');
const IdToken $identical = (_core, 'identical');
const IdToken $hashObjects = (_types, 'hashObjects');
const IdToken $toJsonable = (_serializable, 'ToJsonAble');
const IdToken $caseConverter = (_namesConverter, 'toSomeCase');
const IdToken $namingStrategy = (_namesConverter, 'NamingStrategy');

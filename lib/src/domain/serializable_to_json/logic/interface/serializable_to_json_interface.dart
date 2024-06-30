import '../converter/names_converter.dart';
import '../service/from_json/field_from_json_converter.dart';
import '../service/to_json/field_to_json_converter.dart';

abstract interface class ToJsonAble {
  Map<String, dynamic> toJson();
}

abstract interface class SerializableToJsonInterface {
  String get namingStrategy;

  bool get ignorePrivate;

  NamingStrategy get strategy;

  String toCase(String variableName);

  List<FromJsonConverterFactory> get fromJson;

  List<ToJsonConverterFactory> get toJson;
}

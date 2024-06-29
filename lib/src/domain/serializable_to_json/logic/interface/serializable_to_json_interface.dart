import '../converter/names_converter.dart';

abstract interface class ToJsonAble {
  Map<String, dynamic> toJson();
}

abstract interface class SerializableToJsonInterface {
  String get namingStrategy;

  bool get ignorePrivate;

  NamingStrategy get strategy;

  String toCase(String variableName);
}

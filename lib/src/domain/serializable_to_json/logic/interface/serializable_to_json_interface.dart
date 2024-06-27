import '../macro/serializable_to_json_macro.dart';

abstract interface class ToJsonAble {
  Map<String, dynamic> toJson();
}

abstract interface class SerializableToJsonInterface {
  String get namingStrategy;

  bool get ignorePrivate;

  NamingStrategy get strategy;
}

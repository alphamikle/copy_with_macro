import 'package:macros/macros.dart';

abstract interface class SuperInfo<T> {
  T get original;

  /// If the type is typealias - here will be the real type. Like Json -> Map<String, dynamic>
  TypeDeclaration? get realType;

  Identifier get identifier;

  TypeAnnotation get type;
}

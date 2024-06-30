import 'package:macros/macros.dart';

class FormalParameterDeclarationInfo {
  const FormalParameterDeclarationInfo({
    required this.origin,
    required this.realType,
  });

  final FormalParameterDeclaration origin;

  final TypeDeclaration? realType;

  String get name => origin.name;

  String? get typeName => realType?.identifier.name;

  Identifier get identifier => origin.identifier;
}

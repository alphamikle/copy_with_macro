import 'package:macros/macros.dart';

import '../../../../service/extension/named_type_annotation_extension.dart';
import '../model/formal_parameter_declaration_info.dart';

class FormalParameterDeclarationInfoCollector {
  FormalParameterDeclarationInfoCollector({
    required TypeDefinitionBuilder builder,
  }) : _builder = builder;

  final TypeDefinitionBuilder _builder;

  Future<List<FormalParameterDeclarationInfo>> collect(List<FormalParameterDeclaration> arguments) async {
    return Future.wait(arguments.map(_findInfo));
  }

  Future<FormalParameterDeclarationInfo> _findInfo(FormalParameterDeclaration argument) async {
    final TypeDeclaration? realType = await _realType(argument);

    return FormalParameterDeclarationInfo(
      origin: argument,
      realType: realType,
    );
  }

  Future<TypeDeclaration?> _realType(FormalParameterDeclaration argument) async {
    final TypeAnnotation rawType = argument.type;

    if (rawType is! NamedTypeAnnotation) {
      return null;
    }

    final TypeDeclaration? declaration = await rawType.realDeclarationOf(_builder);
    return declaration;
  }
}

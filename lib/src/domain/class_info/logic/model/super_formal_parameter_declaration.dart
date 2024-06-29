import 'package:macros/macros.dart';

import 'super_info.dart';

class SuperFormalParameterDeclaration implements SuperInfo<FormalParameterDeclaration> {
  const SuperFormalParameterDeclaration({
    required this.original,
    required this.realType,
  });

  @override
  final FormalParameterDeclaration original;

  @override
  final TypeDeclaration realType;

  @override
  Identifier get identifier => original.identifier;

  @override
  TypeAnnotation get type => original.type;
}

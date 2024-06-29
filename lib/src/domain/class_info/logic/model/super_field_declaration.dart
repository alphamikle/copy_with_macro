import 'package:macros/macros.dart';

import 'super_info.dart';

class SuperFieldDeclaration implements SuperInfo<FieldDeclaration> {
  const SuperFieldDeclaration({
    required this.original,
    required this.realType,
  });

  @override
  final FieldDeclaration original;

  @override
  final TypeDeclaration? realType;

  @override
  Identifier get identifier => original.identifier;

  @override
  TypeAnnotation get type => original.type;
}

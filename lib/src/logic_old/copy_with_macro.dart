import 'dart:async';

import 'package:macros/macros.dart';

import 'common_extensions.dart';
import 'macro_extensions.dart';

const String _cp = 'copyWith';

macro class CopyWith implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const CopyWith({
    this.name = '',
  });

  final String name;

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration cla2s, MemberDeclarationBuilder builder) async {
    final ConstructorDeclaration? constructor = await builder.constructorOf(cla2s, name: name);

    if (constructor == null) {
      final List<FieldDeclaration> fields = await builder.allFieldsOf(cla2s);

      if (fields.isEmpty) {
        return _emptyCopyWithDeclaration(builder: builder, cla2s: cla2s);
      }

      if (fields.isProperlyTyped(builder) == false) {
        return;
      }

      final DeclarationCode declaration = DeclarationCode.fromParts([
        '  external ${cla2s.identifier.name} $_cp({',
        for (int i = 0; i < fields.length; i++)
          ...i.spread(fields, (int index, FieldDeclaration field) => [
            field.type.as<NamedTypeAnnotation>().identifier.name,
            if (field.type.as<NamedTypeAnnotation>().isNullable) '?',
            field.identifier.name,
            if (index < fields.length - 1) ', ',
          ]),
        '});',
      ]);

      return builder.declareInType(declaration);
    }

    final ConstructorArgumentsInfo arguments = await builder.argumentsOf(cla2s, name: name);

    if (arguments.isEmpty) {
      return _emptyCopyWithDeclaration(builder: builder, cla2s: cla2s);
    }

    if (arguments.isProperlyTyped(builder) == false) {
      return;
    }

    final List<FieldInfo> allArguments = arguments.all;

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  external ${cla2s.identifier.name} $_cp({',
      for (int i = 0; i < allArguments.length; i++)
        ...i.spread(allArguments, (int index, FieldInfo argument) => [
          argument.type!.as<NamedTypeAnnotation>().identifier.name,
          ' ',
          argument.name,
          if (index < allArguments.length - 1) ', ',
        ]),
      '});'
    ]);

    return builder.declareInType(declaration);
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration cla2s, TypeDefinitionBuilder builder) async {
    final List<MethodDeclaration> methods = await builder.methodsOf(cla2s);
    final MethodDeclaration? copyWithDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == _cp);

    if (copyWithDeclaration == null) {
      return;
    }

    final FunctionDefinitionBuilder copyWithMethod = await builder.buildMethod(copyWithDeclaration.identifier);

    final ConstructorDeclaration? constructor = await builder.constructorOf(cla2s, name: name);

    final String className = cla2s.identifier.name;
    final String constructorName = name == '' ? '' : '.$name';

    if (constructor == null) {
      final List<FieldDeclaration> fields = await builder.allFieldsOf(cla2s);

      if (fields.isEmpty) {
        return _emptyCopyWithDefinition(copyWithMethod: copyWithMethod, className: className, constructorName: constructorName);
      }

      if (fields.isProperlyTyped(builder) == false) {
        return;
      }

      final FunctionBodyCode functionBody = FunctionBodyCode.fromParts([
        '=> ',
        className,
        constructorName,
        '(',
        for (int i = 0; i < fields.length; i++)
          ...i.spread(fields, (int index, FieldDeclaration field) => [
            field.identifier.name,
            ': ',
            field.identifier.name,
            ' ?? ',
            'this.',
            field.identifier.name,
            if (i < fields.length - 1) ', ',
          ]),
        ');'
      ]);

      builder.logInfo('Declaration:');

      return copyWithMethod.augment(functionBody);
    }

    final ConstructorArgumentsInfo arguments = await builder.methodArgumentsOf(cla2s, 'copyWith');

    if (arguments.all.isEmpty) {
      return _emptyCopyWithDefinition(copyWithMethod: copyWithMethod, className: className, constructorName: constructorName);
    }

    if (arguments.isProperlyTyped(builder) == false) {
      return;
    }

    final List<FieldInfo> allArguments = arguments.all;

    // TODO(alphamikle): Read ME:
    /// ! В общем кажется, что проблема в том, что мои кастомные собиратели инфы о полях - кривые и они не хранят инфу о типах полей
    /// ! поэтому надо переделать собирание инфы о полях, а еще лучше - написать план реализации - как именно надо реализовывать этот код
    /// ! типа "вот для такого сценария" - "вот так", а "для такого" - "вот так"
    for (final arg in allArguments) {
      builder.logInfo('''
Argument:
name = ${arg.name}
type = ${arg.type}
code = ${arg.type}
''');
    }

    final FunctionBodyCode functionBody = FunctionBodyCode.fromParts([
      '=> ',
      className,
      constructorName,
      '(',
      for (int i = 0; i < allArguments.length; i++)
        ...i.spread(allArguments, (int index, FieldInfo argument) => [
          argument.name,
          ': ',
          argument.name,
          ' ?? ',
          'this.',
          argument.name,
          if (i < allArguments.length - 1) ', ',
        ]),
      ');'
    ]);

    return copyWithMethod.augment(functionBody);
  }

  void _emptyCopyWithDeclaration({required MemberDeclarationBuilder builder, required ClassDeclaration cla2s}) {
    return builder.declareInType(
      DeclarationCode.fromString('external ${cla2s.identifier.name} copyWith();'),
    );
  }

  void _emptyCopyWithDefinition({
    required FunctionDefinitionBuilder copyWithMethod,
    required String className,
    required String constructorName,
  }) {
    return copyWithMethod.augment(FunctionBodyCode.fromParts([
      '=> ',
      className,
      constructorName,
      '();',
    ]));
  }
}

import 'dart:async';

import 'package:macros/macros.dart';

import 'common_extensions.dart';
import 'macro_extensions.dart';

String _prefixName(String cName) {
  if (cName == '') {
    return 'Unnamed (default) constructor';
  }
  return 'Constructor with name "$cName"';
}

String _trailingName(String cName) {
  if (cName == '') {
    return 'an unnamed (default) constructor';
  }
  return 'a constructor with name "$cName"';
}

macro

class ConstructorMacro implements ClassDeclarationsMacro {
  const ConstructorMacro({
    this.name = '',
  });

  final String name;

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration cla2s, MemberDeclarationBuilder builder) async {
    final ConstructorDeclaration? constructor = await builder.constructorOf(cla2s, name: name);
    if (constructor != null) {
      builder.logInfo('${_prefixName(name)} of class ${cla2s.identifier.name} already exists');
      return;
    }

    final ClassDeclaration? superClass = await builder.superOf(cla2s);
    ConstructorArgumentsInfo superArguments = (positionalFields: {}, namedFields: {}, usedNames: {});

    if (superClass != null) {
      final ConstructorDeclaration? superConstructor = await builder.constructorOf(superClass, name: name);
      if (superConstructor == null) {
        builder.logInfo('Class "${superClass.identifier.name}" should have ${_trailingName(name)}');
        return;
      }
      superArguments = await builder.constructorArgumentsOf(superClass, name: name);
    }

    if (superArguments.isProperlyTyped(builder) == false) {
      return;
    }

    final List<FieldDeclaration> fields = await builder.fieldsOf(cla2s);

    if (fields.isProperlyTyped(builder) == false) {
      return;
    }

    final String constructorName = name == '' ? '' : '.$name';

    final Identifier str = await builder.resolveIdentifier(Uri.parse('dart:core'), 'String');

    if (fields.isEmpty && superArguments.isEmpty) {
      return builder.declareInType(DeclarationCode.fromParts(
        [
          'const ${cla2s.identifier.name}$constructorName();',
          '\n',
          'external ${str.name} get never;',
        ],
      ));
    }

    final List<FieldInfo> allSuperArguments = superArguments.all;

    final DeclarationCode declaration = DeclarationCode.fromParts([
      '  const ${cla2s.identifier.name}$constructorName({',
      for (int i = 0; i < allSuperArguments.length; i++)
        ...i.spread(
            allSuperArguments,
                (int index, FieldInfo argument) =>
            [
              'required ',
              argument.type!.code,
              ' ',
              argument.name,
              ', ',
            ]),
      for (int i = 0; i < fields.length; i++)
        ...i.spread(
            fields,
                (int index, FieldDeclaration field) =>
            [
              'required ',
              'this.',
              field.identifier.name,
              if (i < fields.length - 1) ', ',
            ]),
      '})',
      if (superClass != null) ...[
        ' : super(',
        for (final argument in superArguments.positionalFields) ...[argument.name, ','],
        for (final argument in superArguments.namedFields) ...[argument.name, ': ', argument.name, ', '],
        ')',
      ],
      ';',
    ]);

    return builder.declareInType(declaration);
  }
}

import 'package:macros/macros.dart';

import 'common_extensions.dart';
import 'macro_extensions.dart';

extension ExtendedTypeDefinitionBuilder on TypeDefinitionBuilder {
  Future<MethodDeclaration?> methodDeclarationByName(ClassDeclaration clazz, String name) async {
    final List<MethodDeclaration> methods = await methodsOf(clazz);
    final MethodDeclaration? methodDeclaration = methods.firstWhereOrNull((MethodDeclaration it) => it.identifier.name == name);
    return methodDeclaration;
  }

  Future<FunctionDefinitionBuilder?> methodBuilderByName(ClassDeclaration clazz, String name) async {
    final MethodDeclaration? methodDeclaration = await methodDeclarationByName(clazz, name);

    if (methodDeclaration == null) {
      return null;
    }
    final FunctionDefinitionBuilder method = await buildMethod(methodDeclaration.identifier);
    return method;
  }

  Future<ConstructorDefinitionBuilder?> constructorBuilderByName(ClassDeclaration clazz, String name) async {
    final MethodDeclaration? constructorDeclaration = await constructorOf(clazz, name: name);

    if (constructorDeclaration == null) {
      return null;
    }
    final ConstructorDefinitionBuilder method = await buildConstructor(constructorDeclaration.identifier);
    return method;
  }
}

import 'package:macros/macros.dart';

import 'common_extensions.dart';
import 'identifiers.dart';

typedef FieldName = String;
typedef FieldInfo = ({FieldName name, bool required, bool nullable, TypeAnnotation? type});

extension ExtendedDeclarationPhaseIntrospector on DeclarationPhaseIntrospector {
  Future<ConstructorDeclaration?> constructorOf(TypeDeclaration type, {String name = ''}) async {
    final List<ConstructorDeclaration> constructors = await constructorsOf(type);
    if (constructors.isEmpty) {
      return null;
    }
    final ConstructorDeclaration? target = constructors.firstWhereOrNull((ConstructorDeclaration it) => it.identifier.name == name);
    return target;
  }

  Future<ClassDeclaration?> superOf(ClassDeclaration cla2s) async {
    if (cla2s.superclass == null) {
      return null;
    }
    final TypeDeclaration superConstructor = await typeDeclarationOf(cla2s.superclass!.identifier);
    return superConstructor is ClassDeclaration ? superConstructor : null;
  }
}

extension ExtendedTypePhaseIntrospector on TypePhaseIntrospector {
  Future<Identifier> resolveId(IdToken token) async {
    // TODO(alphamikle): Remove overriding hiding
    // ignore: deprecated_member_use
    return resolveIdentifier(Uri.parse(token.$1), token.$2);
  }

  Future<List<Identifier>> resolveIds(List<IdToken> tokens) async => Future.wait(tokens.map(resolveId));
}

extension ExtendedMacroBuilder on Builder {
  void logInfo(String message) {
    report(
      Diagnostic(
        DiagnosticMessage(message),
        Severity.info,
      ),
    );
  }
}

extension ExtendedTypeAnnotation on TypeAnnotation {
  bool get isNonNullable {
    return isNullable == false;
  }
}

import 'dart:async' as a;
import 'dart:core' as c;
import 'dart:developer';

import 'package:macros/macros.dart' as m;

// macro

class EmptyMacro implements m.ClassDeclarationsMacro {
  const EmptyMacro();

  @c.override
  a.FutureOr<void> buildDeclarationsForClass(m.ClassDeclaration clazz, m.MemberDeclarationBuilder builder) async {
    // inspect(clazz);
    // debugger(message: 'I want to see, what the inside of "copy"');
  }
}

class Experiments {}

void main() {
  // a.

  final expando = c.Expando('newField');
  final experiments = Experiments();

  expando[experiments] = 345;

  debugger();
}

import 'package:copy_with_macro/src/logic/with_constructor_macro.dart';

@WithConstructor()
class User {
  final String name;
  final int age;
}

@WithConstructor(allRequired: false)
@WithConstructor(name: 'raw')
class Pet {
  final String name;
  final int age;
  final int? gender;
}

class ExplicitConstructor {
  const ExplicitConstructor({
    required String this.field,
  });

  final String field;
}

void main() {
  const User mike = User(name: 'Mike', age: 30);
  const Pet ora = Pet.raw(name: 'Ora', age: 10, gender: 0);
  const Pet coca = Pet(name: 'Coca', age: 7);

  print('Mike: $mike; name = ${mike.name}; age = ${mike.age}');
}

import 'package:copy_with_macro/src/domain/serializable_to_json/logic/converter/names_converter.dart';
import 'package:flutter_test/flutter_test.dart';

final List<NameConverter> _converters = [
  toCamelCase,
  toPascalCase,
  toSnakeCase,
  toScreamingSnakeCase,
  toKebabCase,
  toTrainCase,
  toDotCase,
];

// Realistic list of possible dart-names for variables
const List<String> _examples = [
  'camelCaseField',
  'some1Field',
  'snake_case_field',
  r'$someMetaName',
  r'some$Meta$Name',
  'extra123Variant',
  'extraVariant123',
  '_privateField',
  'SCREAMING_SNAKE_CASE_FIELD',
  r'realMeta_$super_UNIQIE_nAmE$',
  r'example_OfAnother_123_namE_$',
  r'___several__un123der_$scores',
  r'__$$$thisIsThe__NAME_OF$_VAriable',
];

const Map<String, List<String>> _splitExamples = {
  'camelCaseField': ['camel', 'case', 'field'],
  'some1Field': ['some', '1', 'field'],
  'snake_case_field': ['snake', 'case', 'field'],
  r'$someMetaName': [r'$some', 'meta', 'name'],
  r'some$Meta$Name': ['some', r'$meta', r'$name'],
  'extra123Variant': ['extra', '123', 'variant'],
  'extraVariant123': ['extra', 'variant', '123'],
  '_privateField': ['_', 'private', 'field'],
  'SCREAMING_SNAKE_CASE_FIELD': ['screaming', 'snake', 'case', 'field'],
  r'realMeta_$super_UNIQIE_nAmE$': ['real', 'meta', r'$super', 'unique', 'n', 'am', r'e$'],
  r'example_OfAnother_123_namE_$': ['example', 'of', 'another', '123', 'nam', 'e', r'$'],
  r'___several__un123der_$scores': ['_', 'several', 'un', '123', 'der', r'$scores'],
  r'__$$$thisIsThe__NAME_OF$_VAriable': ['_', r'$$$this', 'is', 'the', 'name', 'of', r'$', 'variable'],
};

const String camelCaseField = '';
const String some1Field = '';
// ignore: constant_identifier_names
const String snake_case_field = '';
const String $someMetaName = '';
const String some$Meta$Name = '';
const String extra123Variant = '';
const String extraVariant123 = '';
// ignore: unused_element
const String _privateField = '';
// ignore: constant_identifier_names
const String SCREAMING_SNAKE_CASE_FIELD = '';
// ignore: constant_identifier_names
const String realMeta_$super_UNIQIE_nAmE$ = '';
// ignore: constant_identifier_names
const String example_OfAnother_123_namE_$ = '';
// ignore: constant_identifier_names, unused_element
const String ___several__un123der_$scores = '';
// ignore: constant_identifier_names, unused_element
const String __$$$thisIsThe__NAME_OF$_VAriable = '';

const List<List<String>> _results = [
  // toCamelCase
  [
    'camelCaseField',
    'some1Field',
    'snakeCaseField',
    r'$someMetaName',
    r'some$Meta$Name',
    'extra123Variant',
    'extraVariant123',
    '_privateField',
    'screamingSnakeCaseField',
    r'realMeta$SuperUniqieNAmE$',
    r'exampleOfAnother123NamE$',
    r'_severalUn123Der$Scores',
    r'_$$$thisIsTheNameOf$Variable',
  ],
  // ToPascalCase
  [
    'CamelCaseField',
    'Some1Field',
    'SnakeCaseField',
    r'$SomeMetaName',
    r'Some$Meta$Name',
    'Extra123Variant',
    'ExtraVariant123',
    '_PrivateField',
    'ScreamingSnakeCaseField',
    r'RealMeta$SuperUniqieNAmE$',
    r'ExampleOfAnother123NamE$',
    r'_SeveralUn123Der$Scores',
    r'_$$$ThisIsTheNameOf$Variable',
  ],
  // to_snake_case
  [
    'camel_case_field',
    'some_1_field',
    'snake_case_field',
    r'$some_meta_name',
    r'some_$meta_$name',
    'extra_123_variant',
    'extra_variant_123',
    '_private_field',
    'screaming_snake_case_field',
    r'real_meta_$super_uniqie_n_am_e_$',
    r'example_of_another_123_nam_e_$',
    r'_several_un_123_der_$scores',
    r'_$$$this_is_the_name_of_$_variable', // ! Check it
  ],
  // TO_SCREAMING_SNAKE_CASE
  [
    'CAMEL_CASE_FIELD',
    'SOME_1_FIELD',
    'SNAKE_CASE_FIELD',
    r'$SOME_META_NAME',
    r'SOME_$META_$NAME',
    'EXTRA_123_VARIANT',
    'EXTRA_VARIANT_123',
    '_PRIVATE_FIELD',
    'SCREAMING_SNAKE_CASE_FIELD',
    r'REAL_META_$SUPER_UNIQIE_N_AM_E_$',
    r'EXAMPLE_OF_ANOTHER_123_NAM_E_$',
    r'_SEVERAL_UN_123_DER_$SCORES',
    r'_$$$THIS_IS_THE_NAME_OF_$_VARIABLE', // ! Check it
  ],
  // to-kebab-case
  [
    'camel-case-field',
    'some-1-field',
    'snake-case-field',
    r'$some-meta-name',
    r'some-$meta-$name',
    'extra-123-variant',
    'extra-variant-123',
    '_private-field',
    'screaming-snake-case-field',
    r'real-meta-$super-uniqie-n-am-e-$',
    r'example-of-another-123-nam-e-$',
    r'_several-un-123-der-$scores',
    r'_$$$this-is-the-name-of-$-variable', // ! Check it
  ],
  // To-Train-Case
  [
    'Camel-Case-Field',
    'Some-1-Field',
    'Snake-Case-Field',
    r'$Some-Meta-Name',
    r'Some-$Meta-$Name',
    'Extra-123-Variant',
    'Extra-Variant-123',
    '_Private-Field',
    'Screaming-Snake-Case-Field',
    r'Real-Meta-$Super-Uniqie-N-Am-E-$',
    r'Example-Of-Another-123-Nam-E-$',
    r'_Several-Un-123-Der-$Scores',
    r'_$$$This-Is-The-Name-Of-$-Variable', // ! Check it
  ],
  // to.dot.case
  [
    'camel.case.field',
    'some.1.field',
    'snake.case.field',
    r'$some.meta.name',
    r'some.$meta.$name',
    'extra.123.variant',
    'extra.variant.123',
    '_private.field',
    'screaming.snake.case.field',
    r'real.meta.$super.uniqie.n.am.e.$',
    r'example.of.another.123.nam.e.$',
    r'_several.un.123.der.$scores',
    r'_$$$this.is.the.name.of.$.variable', // ! Check it
  ],
];

String _clearConverterName(NameConverter converter) {
  return converter.toString().replaceFirst("Closure: (String) => String from Function '", '').replaceFirst("': static.", '');
}

void main() {
  group('Names Converter Test', () {
    for (int i = 0; i < _converters.length; i++) {
      final NameConverter converter = _converters[i];

      for (int j = 0; j < _examples.length; j++) {
        final String example = _examples[j];

        test('Convert "$example" => "${_clearConverterName(converter)}"', () async {
          expect(converter(example), _results[i][j]);
        });
      }
    }
  });
}

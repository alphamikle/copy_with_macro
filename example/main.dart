import 'package:copy_with_macro/src/domain/serializable_to_json/logic/converter/names_converter.dart';
import 'package:copy_with_macro/src/domain/serializable_to_json/logic/macro/serializable_to_json.dart';

import 'combined_macro.dart';

// void main() {
//   const Genre historicalNovel = Genre(name: "Historical Novel", tonality: Tonality.drama);
//   const Book warAndPeace = Book(
//     title: 'War and Peace',
//     year: 1869,
//     isbn: '978-0-14-303999-0',
//     genres: [
//       historicalNovel,
//     ],
//   );
//
//   final Book hitchhiker = warAndPeace.copyWith(
//     title: 'The Hitchhiker\'s Guide to the Galaxy',
//     year: 1979,
//     genres: [
//       historicalNovel.copyWith(name: 'Science Fiction').copyWithNull(tonality: true),
//     ],
//   ).copyWithNull(isbn: true);
//
//   print(warAndPeace);
//   print(hitchhiker);
//   print(hitchhiker == hitchhiker.copyWith());
// }
//
// @Printable()
// @Equal()
// @CopyWith()
// @WithConstructor()
// class Book {
//   final String title;
//   final int year;
//   final String? isbn;
//   final List<Genre>? genres;
// }

// @CombinedMacro()
// class Genre {
//   final String name;
//   final Tonality? tonality;
// }
//
enum Tonality {
  tragedy,
  comedy,
  drama,
  thriller,
}

class Zero {}

// @SerializableToJson()
// @CombinedMacro()
// class First {
//   final String field1;
// }

@SerializableToJson()
// @CombinedMacro()
class Second {
  final String stringField;
  final int intField;
  final double doubleField;
  final bool boolField;
  final Tonality? enumField;

// final Map<String, dynamic>? mapField;
}

void main() {
  final Second v1 = Second.fromJson(
    {
      'stringField': 'This is String',
      'enumField': 'thriller',
      'intField': 123,
      'boolField': false,
      'doubleField': 0.456,
      'mapField': <String, dynamic>{},
    },
  );
  print(v1);

  final Second v2 = example();

  print(v2);
}

Second example() {
  final Map<String, dynamic> json = {'enumField': 'drama'};

  final Map<String, Tonality> stringToTonality = Tonality.values.asNameMap().map((key, value) => MapEntry(toSomeCase(key, NamingStrategy.plain), value));
  final Map<String, Tonality> stringToTonality2 = Tonality.values.asNameMap().map((key, value) => MapEntry(toSomeCase(key, NamingStrategy.plain), value));
  // final Map<Tonality, String> tonalityToString = Tonality.values.asNameMap().map((String key, Tonality value) => MapEntry(value, convert(key)));

  final Tonality tonality = stringToTonality[json[r'enumField']] as Tonality;

  return Second.$fromJson(
    stringField: 'This is String v2',
    intField: 123,
    boolField: false,
    doubleField: 0.456,
    enumField: Tonality.values.byName(json[r'enumField'].toString()),
    // mapField: <String, dynamic>{},
  );
}

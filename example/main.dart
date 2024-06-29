import 'package:copy_with_macro/src/domain/serializable_to_json/logic/macro/serializable_to_json_macro.dart';

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

typedef Json = Map<String, dynamic>;

// @SerializableToJson()
// class First {
//   final String field1;
// }

@SerializableToJson()
class Second {
  final String field2;
  final Tonality? field3;
  final Map<String, dynamic>? field4;
  final Set<Map<String, dynamic>> field5;
  final Zero field6;
}

void main() {
  // ignore: unused_local_variable
  final Second second = Second.fromJson(
    {
      'field1': 'Boo',
      'field2': 'Foo',
      'field3': 'comedy',
    },
  );
}

String convert(String key) => key;

Second example(Map<String, dynamic> json) {
  final Map<String, Tonality> stringToTonality = Tonality.values.asNameMap().map((String key, Tonality value) => MapEntry(convert(key), value));
  final Map<Tonality, String> tonalityToString = Tonality.values.asNameMap().map((String key, Tonality value) => MapEntry(value, convert(key)));

  return Second.$fromJson(
    // field1: json[r'field1'] as String,
    field2: json[r'field2'] as String,
    field3: stringToTonality[json[r'field3']],
    field4: {},
    field5: {},
    field6: Zero(),
  );
}

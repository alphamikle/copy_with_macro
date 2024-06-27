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

@SerializableToJson()
class First {
  final String field1;
}

@SerializableToJson()
class Second extends First {
  final String field2;
  final Tonality? field3;
}

void main() {
  final Second second = Second.fromJson(
    {
      'field_1': 'Boo',
      'field_2': 'Foo',
      'field_3': 'comedy',
    },
  );
}

Second example(Map<String, dynamic> json) {
  return Second.$fromJson(
    field1: json[r'field_1'] as String,
    field2: json[r'field_2'] as String,
    field3: Tonality.values.firstWhere((Tonality it) => it.name == json[r'field_3']) as Tonality?,
  );
}

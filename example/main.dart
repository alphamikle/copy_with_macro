import 'package:copy_with_macro/copy_with_macro.dart';

import 'extra_macro.dart';

void main() {
  const Genre historicalNovel = Genre(name: "Historical Novel", tonality: Tonality.drama);
  const Book warAndPeace = Book(
    title: 'War and Peace',
    year: 1869,
    isbn: '978-0-14-303999-0',
    genres: [
      historicalNovel,
    ],
  );

  final Book hitchhiker = warAndPeace.copyWith(
    title: 'The Hitchhiker\'s Guide to the Galaxy',
    year: 1979,
    genres: [
      historicalNovel.copyWith(name: 'Science Fiction').copyWithNull(tonality: true),
    ],
  ).copyWithNull();

  final List<Object?> fields = warAndPeace.$fields;
  print(fields);
}

@Equal()
@CopyWith()
@WithConstructor()
class Book {
  final String title;
  final int year;
  final String? isbn;
  final List<Genre>? genres;
}

enum Tonality {
  tragedy,
  comedy,
  drama,
  thriller,
}

@Copy()
class Genre {
  final String name;
  final Tonality? tonality;
}

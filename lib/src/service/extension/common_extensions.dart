import 'package:macros/macros.dart';

import 'macro_extensions.dart';

typedef PresenceTest<T> = bool Function(T it);
typedef Spreader<T> = List<Object> Function(int index, T value);
typedef Mapper<T, V> = V Function(int index, T value);

extension ExtendedList<T> on List<T> {
  T? firstWhereOrNull(PresenceTest<T> test) {
    for (final T item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }

  List<V> mapIndexed<V>(Mapper<T, V?> mapper) {
    final List<V> result = [];
    for (int i = 0; i < length; i++) {
      final V? mapped = mapper(i, this[i]);
      if (mapped != null) {
        result.add(mapped);
      }
    }
    return result;
  }
}

extension ExtendedString on String {
  String mapIndexed(Mapper<String, String?> mapper) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final String? mapped = mapper(i, this[i]);
      if (mapped != null) {
        buffer.write(mapped);
      }
    }
    return buffer.toString();
  }
}

extension ExtendedConstructorArgumentsInfo on ConstructorArgumentsInfo {
  bool get isEmpty {
    return this.positionalFields.isEmpty && this.namedFields.isEmpty;
  }

  List<FieldInfo> get all {
    final List<FieldInfo> allFields = [...this.positionalFields, ...this.namedFields];
    return allFields;
  }

  bool isProperlyTyped(Builder builder) {
    final Set<FieldName> unTypedFields = {};

    for (final positionalField in this.positionalFields) {
      if (positionalField.type == null) {
        unTypedFields.add(positionalField.name);
      }
    }

    for (final namedField in this.namedFields) {
      if (namedField.type == null) {
        unTypedFields.add(namedField.name);
      }
    }

    if (unTypedFields.isNotEmpty) {
      for (final fieldName in unTypedFields) {
        builder.logInfo('Field $fieldName should have explicit type');
      }
    }

    return unTypedFields.isEmpty;
  }
}

extension ExtendedInt on int {
  List<Object> spread<T>(List<T> collection, Spreader<T> spreader) {
    return spreader(this, collection[this]);
  }
}
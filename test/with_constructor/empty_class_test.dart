class EmptyClassTest {}

abstract class L1 {
  const L1();

  abstract final String field;
}

class L2 extends L1 {
  const L2({
    required this.field,
  });

  @override
  final String field;
}

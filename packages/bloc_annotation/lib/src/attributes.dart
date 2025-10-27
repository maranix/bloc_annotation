final class AttributeValue {
  const AttributeValue({
    required this.name,
    required this.type,
    this.isNullable = false,
    this.isNamed = false,
  });

  final String name;
  final Type type;
  final bool isNullable;
  final bool isNamed;
}

final class Attributes {
  const Attributes() : values = const {};

  const Attributes.of(this.values);

  final Set<AttributeValue> values;

  bool get isEmpty => values.isEmpty;
  bool get isNotEmpty => values.isNotEmpty;
}

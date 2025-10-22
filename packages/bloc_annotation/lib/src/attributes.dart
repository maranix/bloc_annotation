final class AttributeValue {
  const AttributeValue({
    required this.name,
    required this.type,
    this.isNullable = false,
  });

  final String name;
  final Type type;
  final bool isNullable;

  @override
  int get hashCode => Object.hash(name, type, isNullable);

  @override
  bool operator ==(covariant AttributeValue other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return name == other.name &&
        type == other.type &&
        isNullable == other.isNullable;
  }
}

final class Attributes {
  const Attributes(this.values);

  final Set<AttributeValue> values;
}

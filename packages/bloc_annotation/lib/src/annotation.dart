abstract class BaseAnnotation {
  const BaseAnnotation({
    this.name = '',
    this.copyWith = true,
    this.overrideEquality = true,
    this.overrideToString = true,
  });

  /// Name of the generated entity will be overriden by the provided value.
  ///
  /// Defaults to the name of the annotated entity with `_$` as prefix.
  final String name;

  /// Attribute indicating whether to enable copyWith method generation.
  ///
  /// Defaults to true.
  final bool copyWith;

  /// Attribute indicating whether to override `==` and `hashCode`.
  ///
  /// Defaults to true.
  final bool overrideEquality;

  /// Attribute indicating whether to override `==` and `hashCode`.
  ///
  /// Defaults to true.
  final bool overrideToString;
}

import 'package:bloc_annotation/src/annotation.dart';

final class StateMeta extends BaseAnnotation {
  const StateMeta({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
    this.isSealed = true,
  });

  final bool isSealed;
}
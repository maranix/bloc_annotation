import 'package:bloc_annotation/src/annotation.dart';

final class BlocMeta extends BaseAnnotation {
  const BlocMeta({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
    this.state,
  });

  final Type? state;
}

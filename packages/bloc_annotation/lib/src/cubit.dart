import 'package:bloc_annotation/src/annotation.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
final class CubitMeta extends BaseAnnotation {
  const CubitMeta({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
    this.state,
  });

  final Type? state;
}

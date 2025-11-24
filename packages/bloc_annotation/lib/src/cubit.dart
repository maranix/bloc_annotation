import 'package:bloc_annotation/src/annotation.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
final class CubitClass<S> extends BaseAnnotation {
  const CubitClass({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
  });
}

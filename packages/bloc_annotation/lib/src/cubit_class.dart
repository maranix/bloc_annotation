import 'package:bloc_annotation/src/annotation.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class CubitClass extends BaseAnnotation {
  const CubitClass({
    super.name,
    super.copyWith,
    super.overrideEquality,
    required this.state,
  });

  final Type state;
}

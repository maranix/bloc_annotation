import 'package:bloc_annotation/src/annotation.dart';

final class BlocClass<E, S> extends BaseAnnotation {
  const BlocClass({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
  });
}

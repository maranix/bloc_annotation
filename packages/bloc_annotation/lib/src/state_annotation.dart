import 'package:bloc_annotation/src/annotation.dart';

final class StateClass extends BaseAnnotation {
  const StateClass({
    super.name,
    super.copyWith,
    super.overrideToString,
    super.overrideEquality,
    this.isSealed = true,
  });

  final bool isSealed;
}

final class StateEnum extends BaseAnnotation {
  const StateEnum({
    super.name,
    super.copyWith,
    super.overrideEquality,
    super.overrideToString,
  });
}

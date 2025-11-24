import 'package:bloc_annotation/src/annotation.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.method})
class EventMeta extends BaseAnnotation {
  const EventMeta({
    super.name,
    super.copyWith,
    super.overrideEquality,
    super.overrideToString,
  });
}

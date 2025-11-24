import 'package:analyzer/dart/element/element.dart' show Element, MethodElement;
import 'package:source_gen/source_gen.dart' show TypeChecker;

/// Type alias for field information used in code generation
typedef FieldInfo = ({String name, String type});

bool hasStateAnnotation(Element element) {
  const stateChecker = TypeChecker.fromUrl(
    'package:bloc_annotation/src/state.dart#StateMeta',
  );
  return stateChecker.hasAnnotationOf(element);
}

bool hasEventAnnotation(MethodElement method) {
  const eventChecker = TypeChecker.fromUrl(
    'package:bloc_annotation/src/event.dart#EventMeta',
  );
  return eventChecker.hasAnnotationOf(method);
}

String capitalize(String? s) {
  if (s == null || s.isEmpty) return s ?? '';
  return s[0].toUpperCase() + s.substring(1);
}

/// Generates a copyWith method body for the given state type and fields
String generateCopyWith(
  String stateType,
  List<FieldInfo> fields,
) {
  if (fields.isEmpty) return 'return state;';

  final params = fields
      .map((f) => '${f.name}: ${f.name} ?? state.${f.name}')
      .join(', ');
  return 'return $stateType($params);';
}

/// Generates a toString method body for the given name and fields
String generateToString(
  String name,
  List<FieldInfo> fields,
) {
  if (fields.isEmpty) return '\'$name(state: \$state)\'';

  final fieldStr = fields
      .map((f) => '${f.name}: \${state.${f.name}}')
      .join(', ');
  return '\'$name($fieldStr, state: \$state)\';';
}

/// Generates a hashCode getter body for the given fields
String generateHashCode(List<FieldInfo> fields) {
  if (fields.isEmpty) return 'state.hashCode';

  final fieldNames = fields.map((f) => 'state.${f.name}').join(', ');
  return 'Object.hashAll([$fieldNames])';
}

/// Generates an equality operator body for the given name and fields
String generateEquality(
  String name,
  List<FieldInfo> fields,
) {
  if (fields.isEmpty) {
    return '''
if (identical(this, other)) return true;
return other is _\$$name && other.state == state;
''';
  }

  final conditions = fields
      .map((f) => 'state.${f.name} == other.state.${f.name}')
      .join(' && ');
  return '''
if (identical(this, other)) return true;
return other is _\$$name && $conditions;
''';
}

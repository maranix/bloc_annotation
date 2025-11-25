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
String generateCopyWith(String stateType, List<FieldInfo> fields) {
  if (fields.isEmpty) return 'return state;';

  final params = fields
      .map((f) => '${f.name}: ${f.name} ?? state.${f.name}')
      .join(', ');
  return 'return $stateType($params);';
}

/// Generates a toString method body for the given name and fields
String generateToString(
  String className,
  List<FieldInfo> fields, {
  bool hasState = true,
}) {
  final escapedName = className.replaceAll('\$', '\\\$');
  if (fields.isEmpty) {
    if (hasState) return '\'$escapedName(state: \$state)\'';
    return '\'$escapedName()\'';
  }

  final fieldStr = fields
      .map((f) {
        if (hasState) {
          return '${f.name}: \${state.${f.name}}';
        } else {
          return '${f.name}: \$${f.name}';
        }
      })
      .join(', ');

  if (hasState) return '\'$escapedName($fieldStr, state: \$state)\'';
  return '\'$escapedName($fieldStr)\'';
}

/// Generates a hashCode getter body for the given fields
String generateHashCode(List<FieldInfo> fields, {bool hasState = true}) {
  if (fields.isEmpty) return hasState ? 'state.hashCode' : '0';

  final fieldNames = fields
      .map((f) => '${hasState ? 'state.' : ''}${f.name}')
      .join(', ');
  return 'Object.hashAll([$fieldNames])';
}

/// Generates an equality operator body for the given name and fields
String generateEquality(
  String className,
  List<FieldInfo> fields, {
  bool hasState = true,
}) {
  if (fields.isEmpty) {
    return '''
if (identical(this, other)) return true;
return other is $className && ${hasState ? 'other.state == state' : 'true'};
''';
  }

  final conditions = fields
      .map(
        (f) =>
            '${hasState ? 'state.' : ''}${f.name} == other.${hasState ? 'state.' : ''}${f.name}',
      )
      .join(' && ');
  return '''
if (identical(this, other)) return true;
return other is $className && $conditions;
''';
}

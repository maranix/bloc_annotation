import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation_generator/src/exceptions.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/types.dart';

abstract class ElementCodeProducer {
  const ElementCodeProducer(this.element);

  final Element element;

  String get name;

  List<ElementAttribute> collectAttributes();

  String copyWith([List<ElementAttribute>? attributes]);

  String overrideToString([List<ElementAttribute>? attributes]);

  String overrideHashCode([List<ElementAttribute>? attributes]);

  String overrideEqualityOperator([List<ElementAttribute>? attributes]);
}

final class ClassCodeProducer extends ElementCodeProducer {
  ClassCodeProducer(super.element, {this.stringifyState = false}) {
    if (!element.kindOf(ElementKind.CLASS)) {
      throw InvalidSourceElementException(
        got: element,
        expected: ElementKind.CLASS,
      );
    }
  }

  final bool stringifyState;

  @override
  String get name => element.displayName;

  @override
  List<ElementAttribute> collectAttributes() => (element as ClassElement).fields
      .where((f) => f.isFinal && f.isPublic)
      .map((f) => (name: f.displayName, type: f.type.getDisplayString()))
      .toList();

  @override
  String copyWith([List<ElementAttribute>? attributes]) {
    final attrs = attributes ?? collectAttributes();
    if (attrs.isEmpty) {
      return '$name()';
    }

    final builder = StringBuffer('return $name(');
    for (final a in attrs.take(attrs.length - 1)) {
      final name = a.name;
      builder.write('$name: $name ?? this.$name)');
    }

    final remainingAttribute = attrs.last.name;
    builder.write(
      '$remainingAttribute: $remainingAttribute ?? this.$remainingAttribute)',
    );

    return builder.toString();
  }

  @override
  String overrideToString([List<ElementAttribute>? attributes]) {
    final attrs = attributes ?? collectAttributes();

    if (attrs.isEmpty) {
      if (stringifyState) return '\'$name(state: \$state)\'';

      return '\'$name()\'';
    }

    final builder = StringBuffer('\'$name(\'');

    for (final a in attrs.take(attrs.length - 1)) {
      final name = a.name;
      builder.write('$name: $name,');
    }

    final remainingAttribute = attrs.last.name;

    if (stringifyState) {
      builder.write('$remainingAttribute: $remainingAttribute,');
      builder.write('state: \$state)\'');
      return builder.toString();
    }

    builder.write('$remainingAttribute: $remainingAttribute)\'');
    return builder.toString();
  }

  @override
  String overrideHashCode([List<ElementAttribute>? attributes]) =>
      'Object.hashAll([${(attributes ?? collectAttributes()).map((a) => a.name).join(', ')}])';

  @override
  String overrideEqualityOperator([List<ElementAttribute>? attributes]) {
    final attrs = attributes ?? collectAttributes();

    final builder = StringBuffer(
      'if (identical(this, other)) return true;'
      '\n'
      'if (other.runtimeType != runtimeType) return false;'
      '\n',
    );

    if (attrs.isEmpty) {
      builder.write('return true;');
      return builder.toString();
    }

    builder.write('return other is $name &&');

    for (final a in attrs.take(attrs.length - 1)) {
      final name = a.name;
      builder.write('$name == this.$name &&');
    }

    final remainingAttribute = attrs.last.name;
    builder.write('$remainingAttribute == this.$remainingAttribute');

    return builder.toString();
  }
}

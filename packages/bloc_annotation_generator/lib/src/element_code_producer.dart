import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation_generator/src/exceptions.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/types.dart';

/// {@template element_code_producer}
/// An abstract base class that defines a contract for generating code
/// representations of source elements (such as classes, methods, or fields).
///
/// Implementations of this class are responsible for:
/// - Collecting and managing attributes (e.g., class fields).
/// - Generating snippets for `copyWith`, `toString`, `hashCode`, and equality operators.
///
/// {@endtemplate}
abstract class ElementCodeProducer {
  /// {@macro element_code_producer}
  const ElementCodeProducer(this.element);

  /// The source element (e.g., a Dart class, field, or method) this producer operates on.
  final Element element;

  /// The name of the element (usually its identifier in source code).
  String get name;

  /// Returns an immutable reference to the internal list of collected element attributes.
  ///
  /// ---
  /// **Important distinction:**
  /// - This getter **only returns** the current internal list of attributes.
  /// - To update or repopulate it based on the current element’s fields,
  ///   refer to [collectAttributes] method.
  List<ElementAttribute> get attributes;

  /// Clears and **re-collects** attributes from the [element].
  ///
  /// Implementations typically filter for relevant fields (e.g., public, final fields)
  /// and repopulate the internal list.
  ///
  /// ---
  /// **Summary of behavior:**
  /// - Clears the existing internal attribute list.
  /// - Scans the underlying [element].
  /// - Adds relevant attributes (such as field name and type) to the internal list.
  ///
  /// Returns a new reference to a list of attributes.
  List<ElementAttribute> collectAttributes();

  /// Generates source code for a `copyWith` method implementation.
  String copyWith();

  /// Generates source code for a `toString` method implementation.
  String overrideToString();

  /// Generates source code for a `hashCode` override.
  String overrideHashCode();

  /// Generates source code for an equality (`==`) operator override.
  String overrideEqualityOperator();
}

/// {@template class_code_producer}
/// A concrete implementation of [ElementCodeProducer] for Dart class elements.
///
/// This class inspects a [ClassElement] and generates:
/// - A `copyWith` method for immutable class updates.
/// - A `toString` method for easy debugging (optionally including a `state`).
/// - Proper `hashCode` and `==` overrides for structural equality.
///
/// {@endtemplate}
final class ClassCodeProducer extends ElementCodeProducer {
  /// {@macro class_code_producer}
  ClassCodeProducer(super.element, {this.stringifyState = false}) {
    if (!element.kindOf(ElementKind.CLASS)) {
      throw InvalidSourceElementException(
        got: element,
        expected: ElementKind.CLASS,
      );
    }
  }

  factory ClassCodeProducer.withCollectedAttributes(
    Element element, {
    bool stringifyState = false,
  }) {
    final producer = ClassCodeProducer(element, stringifyState: stringifyState);
    producer.collectAttributes();

    return producer;
  }

  /// Whether the generated `toString()` should include a `state` field with all the class attributes and its values.
  final bool stringifyState;

  @override
  String get name => element.displayName;

  /// Internal list holding collected attributes (class fields).
  ///
  /// This list is populated by [collectAttributes] and returned by [attributes].
  final List<ElementAttribute> _attributes = [];
  @override
  List<ElementAttribute> get attributes => UnmodifiableListView(_attributes);

  @override
  List<ElementAttribute> collectAttributes() => List.from(
    _attributes
      ..clear()
      ..addAll(
        (element as ClassElement).fields
            .where((f) => f.isFinal && f.isPublic)
            .map((f) => (name: f.displayName, type: f.type.getDisplayString())),
      ),
  );

  @override
  String copyWith() {
    if (_attributes.isEmpty) {
      return '$name()';
    }

    final params = _attributes
        .map((a) => '${a.name}: ${a.name} ?? this.${a.name}')
        .join(', ');

    return 'return $name($params);';
  }

  @override
  String overrideToString() {
    if (_attributes.isEmpty) {
      if (stringifyState) return '\'$name(state: \$state)\'';

      return '\'$name()\'';
    }

    final fields = _attributes.map((a) => '${a.name}: \$${a.name}').join(', ');
    final statePart = stringifyState ? 'state: \$state)\'' : '';

    return '\'$name($fields$statePart)\'';
  }

  @override
  String overrideHashCode() =>
      'Object.hashAll([${_attributes.map((a) => a.name).join(', ')}])';

  @override
  String overrideEqualityOperator() {
    final builder = StringBuffer(
      'if (identical(this, other)) return true;'
      '\n'
      'if (other.runtimeType != runtimeType) return false;'
      '\n',
    );

    if (_attributes.isEmpty) {
      builder.write('return true;');
      return builder.toString();
    }

    builder.write('return other is $name &&');

    for (final a in _attributes.take(_attributes.length - 1)) {
      final name = a.name;
      builder.write('$name == this.$name &&');
    }

    final remainingAttribute = _attributes.last.name;
    builder.write('$remainingAttribute == this.$remainingAttribute');

    return builder.toString();
  }
}

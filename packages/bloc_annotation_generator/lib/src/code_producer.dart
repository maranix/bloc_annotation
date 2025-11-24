import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation_generator/src/exceptions.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/types.dart';

/// {@template class_code_producer}
/// An abstract base class that defines a contract for generating code
/// representations of source elements (such as classes, methods, or fields).
/// {@endtemplate}
abstract class ClassCodeProducer {
  /// {@macro class_code_producer}
  const ClassCodeProducer(this.element);

  /// The source element (e.g., a Dart class, field, or method) this producer operates on.
  final Element element;

  /// The name of the element.
  String get name;

  /// Returns an immutable reference to the internal list of collected element attributes.
  List<ElementAttribute> get attributes;

  /// Defines which [FieldElement] instances from the [element]
  /// should be collected.
  List<FieldElement> get collectableAttributes;

  /// Clears and **re-collects** attributes from the [element].
  List<ElementAttribute> collectAttributes();
}

/// Mixin for generating `copyWith` method.
mixin CopyWithProducer on ClassCodeProducer {
  String copyWith() {
    if (attributes.isEmpty) {
      return '$name()';
    }

    final params = attributes
        .map((a) => '${a.name}: ${a.name} ?? this.${a.name}')
        .join(', ');

    return 'return $name($params);';
  }
}

/// Mixin for generating `toString` method.
mixin ToStringProducer on ClassCodeProducer {
  bool get stringifyState => false;

  String overrideToString() {
    if (attributes.isEmpty) {
      if (stringifyState) return '\'$name(state: \$state)\'';
      return '\'$name()\'';
    }

    final fields = attributes.map((a) => '${a.name}: \$${a.name}').join(', ');
    final statePart = stringifyState ? ', state: \$state)\'' : '';

    return '\'$name($fields$statePart)\';';
  }
}

/// Mixin for generating `hashCode` and `operator ==`.
mixin EqualityProducer on ClassCodeProducer {
  String overrideHashCode() =>
      'Object.hashAll([${attributes.map((a) => a.name).join(', ')}])';

  String overrideEqualityOperator() {
    if (attributes.isEmpty) {
      return '''
if (identical(this, other)) return true;
if (other.runtimeType != runtimeType) return false;
return true;
''';
    }

    final conditions = attributes
        .map((a) => '${a.name} == other.${a.name}')
        .join(' && ');
    return '''
if (identical(this, other)) return true;
if (other.runtimeType != runtimeType) return false;
return other is $name && $conditions;
''';
  }
}

/// {@template basic_class_code_producer}
/// A concrete implementation of [ClassCodeProducer] that uses mixins.
/// {@endtemplate}
final class BasicClassCodeProducer extends ClassCodeProducer
    with CopyWithProducer, ToStringProducer, EqualityProducer {
  /// {@macro basic_class_code_producer}
  BasicClassCodeProducer(super.element, {this.stringifyState = false}) {
    if (!element.kindOf(ElementKind.CLASS)) {
      throw InvalidSourceElementException(
        got: element,
        expected: ElementKind.CLASS,
      );
    }
  }

  factory BasicClassCodeProducer.withCollectedAttributes(
    Element element, {
    bool stringifyState = false,
  }) {
    final producer = BasicClassCodeProducer(
      element,
      stringifyState: stringifyState,
    );
    producer.collectAttributes();

    return producer;
  }

  @override
  final bool stringifyState;

  @override
  String get name => element.displayName;

  final List<ElementAttribute> _attributes = [];
  @override
  List<ElementAttribute> get attributes => UnmodifiableListView(_attributes);

  @override
  List<FieldElement> get collectableAttributes => (element as ClassElement)
      .fields
      .where((f) => f.isFinal && f.isPublic)
      .toList();

  @override
  List<ElementAttribute> collectAttributes() => List.from(
    _attributes
      ..clear()
      ..addAll(
        collectableAttributes.map(
          (f) => (name: f.displayName, type: f.type.getDisplayString()),
        ),
      ),
  );
}

/// {@template event_code_producer}
/// A concrete implementation of [ClassCodeProducer] for Event methods.
/// {@endtemplate}
final class EventCodeProducer extends ClassCodeProducer
    with CopyWithProducer, ToStringProducer, EqualityProducer {
  /// {@macro event_code_producer}
  EventCodeProducer(this.method, {this.stringifyState = false}) : super(method);

  final MethodElement method;

  @override
  final bool stringifyState;

  @override
  String get name => _capitalize(method.name ?? method.displayName);

  final List<ElementAttribute> _attributes = [];
  @override
  List<ElementAttribute> get attributes => UnmodifiableListView(_attributes);

  @override
  List<FieldElement> get collectableAttributes => [];

  @override
  List<ElementAttribute> collectAttributes() {
    _attributes.clear();
    final params = method.formalParameters.where(
      (p) => !p.type.getDisplayString().startsWith('Emitter'),
    );

    for (final p in params) {
      _attributes.add((name: p.name ?? '', type: p.type.getDisplayString()));
    }
    return List.from(_attributes);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

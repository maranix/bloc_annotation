import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/code_producer.dart';
import 'package:bloc_annotation_generator/src/configuration.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for [EventMeta] annotated methods.
final class EventGenerator extends GeneratorForAnnotation<EventMeta> {
  /// Creates a new [EventGenerator] with optional [config].
  EventGenerator([this.config = const GeneratorConfig()]);

  /// The global configuration for this generator.
  final GeneratorConfig config;

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! MethodElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
        todo: 'Remove the @EventMeta annotation from `${element.displayName}`. '
            '@EventMeta can only be applied to methods.',
        element: element,
      );
    }

    final enclosingClass = element.enclosingElement;
    if (enclosingClass is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@EventMeta annotated method must be within a class.',
        todo: 'Move the method `${element.displayName}` inside a class.',
        element: element,
      );
    }

    final eventBaseName = '${enclosingClass.displayName}Event';
    final annotationProps = annotation.getBaseAnnotationProperties();
    
    final producer = EventCodeProducer(element)..collectAttributes();
    
    final eventName = annotationProps.name.isEmpty 
        ? producer.name 
        : annotationProps.name;

    final shouldCopyWith = annotationProps.copyWith && config.copyWith;
    final shouldToString = annotationProps.overrideToString && config.overrideToString;
    final shouldEquality = annotationProps.overrideEquality && config.overrideEquality;

    final params = element.formalParameters
        .where((p) => !p.type.getDisplayString().startsWith('Emitter'))
        .toList();

    final eventClass = Class((b) => b
      ..name = eventName
      ..extend = refer(eventBaseName)
      ..fields.addAll(params.map((p) => Field((f) => f
        ..name = p.name ?? ''
        ..type = refer(p.type.getDisplayString())
        ..modifier = FieldModifier.final$)))
      ..constructors.add(Constructor((c) => c
        ..constant = params.isEmpty
        ..optionalParameters.addAll(params.map((p) => Parameter((param) => param
          ..name = p.name ?? ''
          ..toThis = true
          ..required = p.isRequired || p.isNamed)))))
      ..methods.addAll([
        if (shouldCopyWith && params.isNotEmpty)
          Method((m) => m
            ..returns = refer(eventName)
            ..name = 'copyWith'
            ..lambda = true
            ..optionalParameters.addAll(params.map((p) => Parameter((param) => param
              ..name = p.name ?? ''
              ..type = refer(p.type.getDisplayString()))))
            ..body = Code(producer.copyWith())),
        if (shouldToString)
          Method((m) => m
            ..annotations.add(refer('override'))
            ..returns = refer('String')
            ..name = 'toString'
            ..lambda = true
            ..body = Code(producer.overrideToString())),
        if (shouldEquality) ...[
          Method((m) => m
            ..annotations.add(refer('override'))
            ..returns = refer('int')
            ..type = MethodType.getter
            ..name = 'hashCode'
            ..lambda = true
            ..body = Code(producer.overrideHashCode())),
          Method((m) => m
            ..annotations.add(refer('override'))
            ..returns = refer('bool')
            ..name = 'operator =='
            ..requiredParameters.add(Parameter((p) => p
              ..name = 'other'
              ..covariant = true
              ..type = refer(eventName)))
            ..body = Code(producer.overrideEqualityOperator())),
        ],
      ]));

    final emitter = DartEmitter();
    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(eventClass.accept(emitter).toString());
  }
}

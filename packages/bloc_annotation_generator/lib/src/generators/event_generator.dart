import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/configuration.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/utils.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for [EventClass] annotated classes.
final class EventGenerator extends GeneratorForAnnotation<EventClass> {
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
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
        todo:
            'Remove the @EventClass annotation from `${element.displayName}`. '
            '@EventClass can only be applied to classes.',
        element: element,
      );
    }

    final annotationProps = annotation.getBaseAnnotationProperties();
    final shouldToString =
        annotationProps.overrideToString && config.overrideToString;
    final shouldEquality =
        annotationProps.overrideEquality && config.overrideEquality;

    final buffer = StringBuffer();
    final emitter = DartEmitter();

    // Iterate over factory constructors
    for (final constructor in element.constructors) {
      if (!constructor.isFactory) continue;

      // Skip default factory if any? Usually named factories are used.
      if (constructor.name?.isEmpty ?? true) continue;

      // The factory may not have a resolved redirectedConstructor yet (the part file is being generated).
      // In that case we derive the generated class name using the convention
      //   _$<ParentClassName><FactoryName> (factory name capitalized).
      // e.g. for `RandomFactEvent.fetchRandomFact` we expect `_\$RandomFactEventFetchRandomFact`.
      final redirectedConstructor = constructor.redirectedConstructor;

      String generatedClassName;
      if (redirectedConstructor != null) {
        generatedClassName =
            redirectedConstructor.returnType.element.displayName;
      } else {
        // Fallback: derive name from parent class (without the trailing 'Event' suffix) and factory name, capitalizing the factory name.
        final factoryName = constructor.name ?? '';
        final capitalizedFactory = capitalize(factoryName);
        // Remove trailing 'Event' from the parent class name if present.
        final parentName = element.displayName;
        final baseName = parentName.endsWith('Event')
            ? parentName.substring(0, parentName.length - 'Event'.length)
            : parentName;
        generatedClassName = '_\$$baseName$capitalizedFactory';
      }

      // Generate the class
      // Use the factory's formal parameters (named or positional) for the generated class fields.
      final params = constructor.formalParameters.toList();

      final generatedClass = Class(
        (b) => b
          ..name = generatedClassName
          ..modifier = ClassModifier.final$
          ..extend = refer(element.displayName)
          ..fields.addAll(
            params.map(
              (p) => Field(
                (f) => f
                  ..name = p.name ?? ''
                  ..type = refer(p.type.getDisplayString())
                  ..modifier = FieldModifier.final$,
              ),
            ),
          )
          ..constructors.add(
            Constructor(
              (c) => c
                ..constant =
                    true // TODO: Check if fields allow const and parent has const constructor
                ..requiredParameters.addAll(
                  params
                      .where((p) => !p.isNamed)
                      .map(
                        (p) => Parameter(
                          (param) => param
                            ..name = p.name ?? ''
                            ..toThis = true,
                        ),
                      ),
                )
                ..optionalParameters.addAll(
                  params
                      .where((p) => p.isNamed)
                      .map(
                        (p) => Parameter(
                          (param) => param
                            ..name = p.name ?? ''
                            ..toThis = true
                            ..named = true
                            ..required = p.isRequired,
                        ),
                      ),
                ),
            ),
          )
          ..methods.addAll([
            if (shouldToString && params.isNotEmpty)
              Method(
                (m) => m
                  ..annotations.add(refer('override'))
                  ..returns = refer('String')
                  ..name = 'toString'
                  ..lambda = true
                  ..body = Code(
                    generateToString(
                      generatedClassName,
                      params
                          .map(
                            (p) => (
                              name: p.name ?? '',
                              type: p.type.getDisplayString(),
                            ),
                          )
                          .toList(),
                      hasState: false,
                    ),
                  ),
              ),
            if (shouldEquality && params.isNotEmpty) ...[
              Method(
                (m) => m
                  ..annotations.add(refer('override'))
                  ..returns = refer('int')
                  ..type = MethodType.getter
                  ..name = 'hashCode'
                  ..lambda = true
                  ..body = Code(
                    generateHashCode(
                      params
                          .map(
                            (p) => (
                              name: p.name ?? '',
                              type: p.type.getDisplayString(),
                            ),
                          )
                          .toList(),
                      hasState: false,
                    ),
                  ),
              ),
              Method(
                (m) => m
                  ..annotations.add(refer('override'))
                  ..returns = refer('bool')
                  ..name = 'operator =='
                  ..requiredParameters.add(
                    Parameter(
                      (p) => p
                        ..name = 'other'
                        ..type = refer('Object'),
                    ),
                  )
                  ..body = Code(
                    generateEquality(
                      generatedClassName,
                      params
                          .map(
                            (p) => (
                              name: p.name ?? '',
                              type: p.type.getDisplayString(),
                            ),
                          )
                          .toList(),
                      hasState: false,
                    ),
                  ),
              ),
            ],
          ]),
      );

      buffer.writeln(generatedClass.accept(emitter));
    }

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString());
  }
}

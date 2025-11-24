import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'package:bloc_annotation_generator/src/configuration.dart';

/// Generator for [BlocClass] annotated classes.
final class BlocGenerator extends GeneratorForAnnotation<BlocClass> {
  /// Creates a new [BlocGenerator] with optional [config].
  BlocGenerator([this.config = const GeneratorConfig()]);

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
        todo: 'Remove the @BlocClass annotation from `${element.displayName}`.',
        element: element,
      );
    }

    final annotationProps = annotation.getBlocAnnotationProperties();
    final name = annotationProps.name.isEmpty
        ? element.displayName
        : annotationProps.name;
    final className = '_\$$name';

    // 1. Determine Event and State Types from generics
    final dartType = annotation.objectValue.type;
    if (dartType is! InterfaceType) {
      throw InvalidGenerationSourceError(
        'Annotation must be a class type.',
        element: element,
      );
    }

    if (dartType.typeArguments.length != 2) {
      throw InvalidGenerationSourceError(
        'BlocClass annotation must have exactly 2 type arguments: Event and State.',
        element: element,
      );
    }

    final eventType = dartType.typeArguments[0].getDisplayString();
    final stateType = dartType.typeArguments[1].getDisplayString();

    // Generate Bloc Class - users will manually define events and register handlers
    final blocClass = Class(
      (b) => b
        ..name = className
        ..abstract = true
        ..extend = refer('Bloc<$eventType, $stateType>')
        ..constructors.add(
          Constructor(
            (c) => c
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'initialState'
                    ..toSuper = true,
                ),
              ),
          ),
        ),
    );

    final emitter = DartEmitter();
    final buffer = StringBuffer();

    buffer.writeln(blocClass.accept(emitter));

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString());
  }
}

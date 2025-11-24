import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/configuration.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/utils.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

final class CubitGenerator extends GeneratorForAnnotation<CubitMeta> {
  /// Creates a new [CubitGenerator] with optional [config].
  CubitGenerator([this.config = const GeneratorConfig()]);

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
        todo: 'Remove the @CubitMeta annotation from `${element.displayName}`.',
        element: element,
      );
    }

    final annotationProps = annotation.getCubitAnnotationProperties();

    final name = switch (annotationProps.name.isEmpty) {
      false => annotationProps.name,
      true => element.displayName,
    };

    // 1. Determine State Type
    String? stateType = annotationProps.state;

    // If not provided in annotation, try to infer from @StateMeta annotated field
    if (stateType == null) {
      for (final field in element.fields) {
        if (hasStateAnnotation(field)) {
          stateType = field.type.getDisplayString();
          break;
        }
      }
    }

    if (stateType == null) {
      throw InvalidGenerationSourceError(
        'Could not determine state type for `${element.displayName}`.',
        todo: 'Provide state type explicitly: @CubitMeta(state: YourStateType)',
        element: element,
      );
    }

    final shouldCopyWith = annotationProps.copyWith && config.copyWith;
    final shouldToString =
        annotationProps.overrideToString && config.overrideToString;
    final shouldEquality =
        annotationProps.overrideEquality && config.overrideEquality;

    // Collect state fields for generating methods
    final stateFields = element.fields
        .where((f) => f.isFinal && f.isPublic && !f.isStatic)
        .map((f) => (name: f.displayName, type: f.type.getDisplayString()))
        .toList();

    final generatedClass = Class(
      (b) => b
        ..abstract = true
        ..name = "_\$$name"
        ..extend = refer('Cubit<$stateType>')
        ..constructors.add(
          Constructor(
            (c) => c
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..toSuper = true
                    ..name = "initialState",
                ),
              ),
          ),
        )
        ..methods.addAll([
          // copyWith
          if (shouldCopyWith && stateFields.isNotEmpty)
            Method(
              (m) => m
                ..returns = refer(stateType!)
                ..name = 'copyWith'
                ..optionalParameters.addAll(
                  stateFields.map(
                    (f) => Parameter(
                      (p) => p
                        ..name = f.name
                        ..type = refer(f.type)
                        ..named = true,
                    ),
                  ),
                )
                ..body = Code(generateCopyWith(stateType!, stateFields)),
            ),
          // toString
          if (shouldToString)
            Method(
              (m) => m
                ..annotations.add(refer('override'))
                ..returns = refer('String')
                ..name = 'toString'
                ..lambda = true
                ..body = Code(generateToString(name, stateFields)),
            ),
          // hashCode
          if (shouldEquality)
            Method(
              (m) => m
                ..annotations.add(refer('override'))
                ..returns = refer('int')
                ..type = MethodType.getter
                ..name = 'hashCode'
                ..lambda = true
                ..body = Code(generateHashCode(stateFields)),
            ),
          // operator ==
          if (shouldEquality)
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
                ..body = Code(generateEquality(name, stateFields)),
            ),
        ]),
    );

    final emitter = DartEmitter();

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format("${generatedClass.accept(emitter)}");
  }
}

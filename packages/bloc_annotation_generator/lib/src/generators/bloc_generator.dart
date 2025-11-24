import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:bloc_annotation_generator/src/utils.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'package:bloc_annotation_generator/src/configuration.dart';

/// Generator for [BlocMeta] annotated classes.
final class BlocGenerator extends GeneratorForAnnotation<BlocMeta> {
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
        todo: 'Remove the @BlocMeta annotation from `${element.displayName}`.',
        element: element,
      );
    }

    final annotationProps = annotation.getBlocAnnotationProperties();
    final name = annotationProps.name.isEmpty 
        ? element.displayName 
        : annotationProps.name;
    final className = '_\$$name';

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
        todo:
            'Provide state type explicitly: @BlocMeta(state: YourStateType)',
        element: element,
      );
    }

    // 2. Parse @Event methods
    final eventMethods = element.methods.where(hasEventAnnotation).toList();
    final eventBaseName = '${element.displayName}Event';

    // 3. Generate Base Event Class
    final eventBaseClass = Class(
      (b) => b
        ..name = eventBaseName
        ..sealed = true
        ..abstract = true,
    );

    // 4. Generate Bloc Class
    final blocClass = Class(
      (b) => b
        ..name = className
        ..abstract = true
        ..extend = refer('Bloc<$eventBaseName, $stateType>')
        ..constructors.add(
          Constructor(
            (c) => c
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'initialState'
                    ..toSuper = true,
                ),
              )
              ..body = Block.of(
                eventMethods.map((method) {
                  final eventName = capitalize(method.name);
                  final hasEmitter = method.formalParameters.any(
                    (p) => p.type.getDisplayString().startsWith('Emitter'),
                  );

                  final args = method.formalParameters
                      .where(
                        (p) => !p.type.getDisplayString().startsWith('Emitter'),
                      )
                      .map((p) => 'event.${p.name ?? ''}')
                      .join(', ');

                  final callArgs = [
                    if (args.isNotEmpty) args,
                    if (hasEmitter) 'emit',
                  ].where((s) => s.isNotEmpty).join(', ');

                  return Code(
                    'on<$eventName>((event, emit) => ${method.name}($callArgs));',
                  );
                }),
              ),
          ),
        )
        ..methods.addAll(
          eventMethods.map((method) {
            return Method(
              (m) => m
                ..name = method.name
                ..returns = refer(method.returnType.getDisplayString())
                ..requiredParameters.addAll(
                  method.formalParameters.map(
                    (p) => Parameter(
                      (param) => param
                        ..name = p.name ?? ''
                        ..type = refer(p.type.getDisplayString()),
                    ),
                  ),
                ),
            );
          }),
        ),
    );

    final emitter = DartEmitter();
    final buffer = StringBuffer();

    buffer.writeln(eventBaseClass.accept(emitter));
    buffer.writeln(blocClass.accept(emitter));

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString());
  }
}

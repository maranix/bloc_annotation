import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/configuration.dart';
import 'package:bloc_annotation_generator/src/utils.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for [BlocClass] annotated classes.
final class BlocGenerator
    extends GeneratorForAnnotation<BlocClass<dynamic, dynamic>> {
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

    final name = annotation.read('name').stringValue;
    final blocName = name.isEmpty ? element.displayName : name;
    final className = '_\$$blocName';

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

    final eventType = dartType.typeArguments[0];
    final stateType = dartType.typeArguments[1];
    final eventTypeString = eventType.getDisplayString();
    final stateTypeString = stateType.getDisplayString();

    final eventElement = eventType.element;
    if (eventElement == null || eventElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Event type `${eventType.getDisplayString()}` is not a class or could not be resolved.',
        element: element,
      );
    }

    final onRegistrations = <Code>[];
    final eventHandlers = <Method>[];

    for (final constructor in eventElement.constructors) {
      if (!constructor.isFactory || (constructor.name?.isEmpty ?? true)) {
        continue;
      }

      final factoryName = constructor.name!;
      final capitalizedFactory = capitalize(factoryName);
      final parentName = eventElement.displayName;
      final baseName = parentName.endsWith('Event')
          ? parentName.substring(0, parentName.length - 'Event'.length)
          : parentName;
      final eventClassName = '_\$$baseName$capitalizedFactory';
      final handlerMethodName = '_on$capitalizedFactory';

      onRegistrations.add(
        refer('on')
            .call([refer(handlerMethodName)], {}, [refer(eventClassName)])
            .statement,
      );

      eventHandlers.add(
        Method(
          (b) => b
            ..name = handlerMethodName
            ..returns = refer('void')
            ..requiredParameters.addAll([
              Parameter(
                (p) => p
                  ..name = 'event'
                  ..type = refer(eventClassName),
              ),
              Parameter(
                (p) => p
                  ..name = 'emit'
                  ..type = refer('Emitter<$stateTypeString>'),
              ),
            ]),
        ),
      );
    }

    // Generate Bloc Class - users will manually define events and register handlers
    final blocClass = Class(
      (b) => b
        ..name = className
        ..abstract = true
        ..extend = refer('Bloc<$eventTypeString, $stateTypeString>')
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
              ..body = Block.of(onRegistrations),
          ),
        )
        ..methods.addAll(eventHandlers),
    );

    final emitter = DartEmitter();
    final buffer = StringBuffer()..writeln(blocClass.accept(emitter));

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString());
  }
}

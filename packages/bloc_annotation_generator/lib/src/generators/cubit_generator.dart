import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/element_code_producer.dart';
import 'package:bloc_annotation_generator/src/extensions.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';

final class CubitClassGenerator extends GeneratorForAnnotation<CubitClass> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final elementProducer = ClassCodeProducer(element, stringifyState: true);

    final annotationProps = annotation.getCubitClassAnnotationProperties();

    final name = switch (annotationProps.name.isEmpty) {
      false => annotationProps.name,
      true => elementProducer.name,
    };

    final generatedClass = Class(
      (b) => b
        ..abstract = true
        ..name = "_\$$name"
        ..extend = refer('Cubit<${annotationProps.state}>')
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
          if (annotationProps.copyWith)
            Method(
              (m) => m
                ..returns = refer(name)
                ..name = 'copyWith'
                ..lambda = true
                ..optionalParameters.addAll(
                  elementProducer.attributes.map(
                    (a) => Parameter(
                      (p) => p
                        ..name = a.name
                        ..type = refer(a.type),
                    ),
                  ),
                )
                ..body = Code(elementProducer.copyWith()),
            ),
          // toString
          if (annotationProps.overrideToString)
            Method(
              (m) => m
                ..annotations.add(refer('override'))
                ..returns = refer('String')
                ..name = 'toString'
                ..lambda = true
                ..body = Code(elementProducer.overrideToString()),
            ),
          // override hashcode
          if (annotationProps.overrideEquality) ...[
            Method(
              (m) => m
                ..annotations.add(refer('override'))
                ..returns = refer('int')
                ..type = MethodType.getter
                ..name = 'hashCode'
                ..lambda = true
                ..body = Code(elementProducer.overrideHashCode()),
            ),
            // override equality
            Method(
              (m) => m
                ..annotations.add(refer('override'))
                ..returns = refer('bool')
                ..name = 'operator =='
                ..requiredParameters.add(
                  Parameter(
                    (p) => p
                      ..name = 'other'
                      ..covariant = true
                      ..type = refer(name),
                  ),
                )
                ..body = Code(elementProducer.overrideEqualityOperator()),
            ),
          ],
        ]),
    );

    final emitter = DartEmitter();

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format("${generatedClass.accept(emitter)}");
  }
}
